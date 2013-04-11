# milia

Milia is a multi-tenanting gem for hosted Rails 3.1 applications which use
devise for user authentication.

## Basic concepts

* should be transparent to the main application code
* should be symbiotic with user authentication
* should raise exceptions upon attempted illegal access
* should force tenanting (not allow sloppy access to all tenant records)
* should allow application flexibility upon new tenant sign-up, usage of eula information, etc
* should be as non-invasive (as possible) to Rails code
* row-based tenanting is used
* default_scope is used to enforce tenanting

The author used schema-based tenanting in the past but found it deficient for
the following reasons: most DBMS are optimized to handle enormous number of
rows but not an enormous number of schema (tables). Schema-based tenancy took a
performance hit, was seriously time-consuming to backup and restore, was invasive
into the Rails code structure (monkey patching), was complex to implement, and
couldn't use Rails migration tools as-is.

## Structure

* necessary models: user, tenant
* necessary migrations: user, tenant, tenants_users (join table)

## Dependency requirements

* Rails 3.1 or higher
* Devise 1.4.8 or higher

## Installation

Either install the gem manually:

```
  $ gem install milia
```

Or in the Gemfile:

```ruby
  gem 'milia'
```
  
## Getting started

### Rails setup

Milia expects a user session, so please set one up

```
  $ rails g session_migration
      invoke  active_record
      create    db/migrate/20111012060818_add_sessions_table.rb
```
  
### Devise setup

* See https://github.com/plataformatec/devise for how to set up devise.
* The current version of milia requires that devise use a *User* model.

### Milia setup

#### migrations

*ALL* models require a tenanting field, whether they are to be universal or to
be tenanted. So make sure the following is added to each migration

<i>db/migrate</i>

```ruby
  t.references :tenant
```

Tenanted models will also require indexes for the tenant field:

```ruby
  add_index :TABLE, :tenant_id
```

Also create a tenants_users join table:

<i>db/migrate/20111008081639_create_tenants_users.rb</i>

```ruby
  class CreateTenantsUsers < ActiveRecord::Migration
    def change
      create_table :tenants_users, :id => false  do |t|
        t.references   :tenant
        t.references   :user
      end
      add_index :tenants_users, :tenant_id
      add_index :tenants_users, :user_id
    end
  end
```

#### application controller

add the following line AFTER the devise-required filter for authentications:

<i>app/controllers/application_controller.rb</i>

```ruby
  before_filter :authenticate_tenant!   # authenticate user and setup tenant

# ------------------------------------------------------------------------------
# authenticate_tenant! -- authorization & tenant setup
# -- authenticates user
# -- sets current tenant
# -- sets up app environment for this user
# ------------------------------------------------------------------------------
  def authenticate_tenant!()

    unless authenticate_user!
      email = ( params.nil? || params[:user].nil?  ?  ""  : " as: " + params[:user][:email] )

      flash[:notice] = "cannot sign you in#{email}; check email/password and try again"
      
      return false  # abort the before_filter chain
    end

    # user_signed_in? == true also means current_user returns valid user
    raise SecurityError,"*** invalid sign-in  ***" unless user_signed_in?

    set_current_tenant   # relies on current_user being non-nil
    
    # any application-specific environment set up goes here
    
    true  # allows before filter chain to continue
  end

```


catch any exceptions with the following (be sure to also add the designated methods!)

```ruby
  rescue_from ::Milia::Control::MaxTenantExceeded, :with => :max_tenants
  rescue_from ::Milia::Control::InvalidTenantAccess, :with => :invalid_tenant
```

You'll need to place prep_signup_view method in application_controller.rb; it sets up any attributes required by your signup form. below is the example from my application.

```ruby
# ------------------------------------------------------------------------------
  # klass_option_obj -- returns a (new?) object of a given klass
  # purpose is to handle the variety of ways to prepare for a view
  # args:
  #   klass -- class of object to be returned
  #   option_obj -- any one of the following
  #       -- nil -- will return klass.new
  #       -- object -- will return the object itself
  #       -- hash   -- will return klass.new( hash ) for parameters
# ------------------------------------------------------------------------------
  def klass_option_obj(klass, option_obj)
    return option_obj if option_obj.instance_of?(klass)
    option_obj ||= {}  # if nil, makes it empty hash
    return klass.send( :new, option_obj )
  end  

# ------------------------------------------------------------------------------
  # prep_signup_view -- prepares for the signup view
  # args:
  #   tenant: either existing tenant obj or params for tenant
  #   user:   either existing user obj or params for user
# ------------------------------------------------------------------------------
  def prep_signup_view(tenant=nil, user=nil, coupon='')
    @user   = klass_option_obj( User, user )
    @tenant = klass_option_obj( Tenant, tenant )
    @coupon = coupon
    @eula   = Eula.get_latest.first
 end
```

My signup form has fields for user's email, organization's name (tenant model), coupon code, and current EULA version.


#### routes

Add the following line into the devise_for :users block

<i>config/routes.rb</i>

```ruby
  devise_for :users do
    post  "users" => "milia/registrations#create"
  end
```
  
### Designate which model determines account

Add the following acts_as_... to designate which model will be used as the key
into tenants_users to find the tenant for a given user. 
Only designate one model in this manner.

<i>app/models/user.rb</i>

```ruby
  class User < ActiveRecord::Base
    
    acts_as_universal_and_determines_account
  
  end  # class User
```

### Designate which model determines tenant

Add the following acts_as_... to designate which model will be used as the
tenant model. It is this id field which designates the tenant for an entire 
group of users which exist within a single tenanted domain.
Only designate one model in this manner.

<i>app/models/tenant.rb</i>

```ruby
  class Tenant < ActiveRecord::Base
    
    acts_as_universal_and_determines_tenant
    
  end  # class Tenant
```

### Designate universal models

Add the following acts_as_universal to *ALL* models which are to be universal and
remove any superfluous
  
```ruby
  belongs_to  :tenant
```
  
which the generator might have generated ( acts_as_tenant will specify that ).

<i>app/models/eula.rb</i>

```ruby
  class Eula < ActiveRecord::Base
    
    acts_as_universal
  
  end  # class Eula
```

### Designate tenanted models

Add the following acts_as_tenant to *ALL* models which are to be tenanted and
remove any superfluous
  
```ruby
  belongs_to  :tenant
```
  
which the generator might have generated ( acts_as_tenant will specify that ).

<i>app/models/post.rb</i>

```ruby
  class Post < ActiveRecord::Base
    
    acts_as_tenant
  
  end  # class Post
```


### Exceptions raised

```ruby
  Milia::Control::InvalidTenantAccess
  Milia::Control::MaxTenantExceeded
```

### Tenant pre-processing hooks

#### Milia expects a tenant pre-processing & setup hook:

```ruby
  Tenant.create_new_tenant(params)   # see sample code below
```
  
where the sign-up params are passed, the new tenant must be validated, created,
and then returned. Any other kinds of prepatory processing are permitted here,
but should be minimal, and should not involve any tenanted models. At this point
in the new account sign-up chain, no tenant has been set up yet (but will be
immediately after the new tenant has been created).

<i>app/models/tenant.rb</i>

```ruby
  def self.create_new_tenant(params)
    
    tenant # Tenant.new(:cname => params[:user][:email], :company => params[:tenant][:company])

    if new_signups_not_permitted?(params)
      
      raise ::Milia::Control::MaxTenantExceeded, "Sorry, new accounts not permitted at this time" 
      
    else 
      tenant.save    # create the tenant
    end
    return tenant
  end
```

#### Milia expects a tenant post-processing hook:

```ruby
  Tenant.tenant_signup(user,tenant,other)   # see sample code below
```
  
The purpose here is to do any tenant initialization AFTER devise
has validated and created a user. Objects for the user and tenant
are passed.  It is recommended that only minimal processing be done
here ... for example, queueing a background task to do the actual
work in setting things up for a new tenant.

<i>app/models/tenant.rb</i>

```ruby
# ------------------------------------------------------------------------
# tenant_signup -- setup a new tenant in the system
# CALLBACK from devise RegistrationsController (milia override)
# AFTER user creation and current_tenant established
# args:
#   user  -- new user  obj
#   tenant -- new tenant obj
#   other  -- any other parameter string from initial request
# ------------------------------------------------------------------------
  def self.tenant_signup(user, tenant, other = nil)
    StartupJob.queue_startup( tenant, user, other )
  end
```


### Alternate use case: user belongs to multiple tenants

Your application might allow a user to belong to multiple tenants. You will need
to provide some type of mechanism to allow the user to choose which account
(thus tenant) they wish to access. Once chosen, in your controller, you will need
to put:

<i>app/controllers/any_controller.rb</i>
  
```ruby
  set_current_tenant( new_tenant_id )
```

## joins might require additional tenanting restrictions

Subordinate join tables will not get the Rails default scope.
Theoretically, the default scope on the master table alone should be sufficient
in restricting answers to the current_tenant alone .. HOWEVER, it doesn't feel
right. 

If the master table for the join is a universal table, however, you really *MUST*
use the following workaround, otherwise the database will access data in other 
tenanted areas even if no records are returned. This is a potential security
breach. Further details can be found in various discussions about the
behavior of databases such as POSTGRES.

The milia workaround is to add an additional .where( where_restrict_tenants(klass1, klass2,...))
for each of the subordinate models in the join.

### usage of where_restrict_tenants

```ruby
    Comment.joins(stuff).where( where_restrict_tenants(Post, Author) ).all
```

## console

Note that even when running the console ($ rails console) will be run in 
multi-tenanting mode. You will need to establish a current_user and
setup the current_tenant, otherwise most Model DB accesses will fail.

For the author's own application, I have set up a small ruby file which I 
load when I start the console. This does the following:

```ruby
    def change_tenant(my_id,my_tenant_id)
      @me = User.find( my_id )
      @w  = Tenant.find( my_tenant_id )
      Tenant.set_current_tenant @w
    end

change_tenant(1,1)   # or whatever is an appropriate starting user, tenant
```



## Cautions

* Milia designates a default_scope for all models (both universal and tenanted). From Rails 3.2 onwards, the last designated default scope overrides any prior scopes and will invalidate multi-tenanting; so *DO NOT USE default_scope*
* Milia uses Thread.current[:tenant_id] to hold the current tenant for the existing Action request in the application.
* SQL statements executed outside the context of ActiveRecord pose a potential danger; the current milia implementation does not extend to the DB connection level and so cannot enforce tenanting at this point.
* The tenant_id of a universal model will always be forced to nil.
* The tenant_id of a tenanted model will be set to the current_tenant of the current_user upon creation.


## Contributing to milia
 
* Check out the latest master to make sure the feature hasn't been implemented or the bug hasn't been fixed yet
* Check out the issue tracker to make sure someone already hasn't requested it and/or contributed it
* Fork the project
* Start a feature/bugfix branch
* Commit and push until you are happy with your contribution
* Make sure to add tests for it. This is important so I don't break it in a future version unintentionally.
* Please try not to mess with the Rakefile, version, or history. If you want to have your own version, or is otherwise necessary, that is fine, but please isolate to its own commit so I can cherry-pick around it.

## Copyright

Copyright (c) 2011 Daudi Amani. See LICENSE.txt for further details.

