# milia

Milia is a multi-tenanting gem for hosted Rails 4.0.x applications which use
the devise gem for user authentication and registrations.

## Basic concepts for the milia multi-tenanting gem

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

A tenant == an organization; users == members of the organization. 
Only organizations sign up for new tenants, not members (users).  
The very first user of an organization, let's call him the Organizer, 
is the one responsible for initiating the organizational signup.
The Organizer becomes the first member (user) of the organization (tenant). 
Thereafter, other members only obtain entry to the organization (tenant) 
by invitation. New tenants are not created for every new user.

## Version

milia v1.0.0-beta-2 is the beta version for Rails 4.0.x and is now available for usage.
please use branch: v1.0.0-beta-2 for trying it out
The last previous version for Rails 3.2.x can be found in the git branch 'v0.3'

## What's changed?

* Rails 4.0 adapted (changes to terms, strong_parameters, default_scope, etc)
* Devise 3.2 adapted
* All the changes which version 0.3.x advised to be inserted in applications_controller.rb are now automatically loaded into ActionController by milia.
* that includes authenticate_tenant!
* so if you've been using an older version of milia, you'll need to remove that stuff from applications_controller!

## Sample app and documentation

There were numerous requests for me to provide a complete sample web application
which uses milia and devise. I have done this.

* see doc/sample.sh for complete step-by-step instructions for setting up and creating a working app.
* the sample.sh instructions are very detailed and loaded with comments (600 lines!).
* the sample app uses web-theme-app to provide some pleasantly formatted views for your testing pleasure.
* the instructions take you to three stages: 
  - one with simple devise and no milia, 
  - two installing milia for complete tenanting,
  - three adding in invite_member capability
* doc/ directory has a sample milia-initializer.rb for adding to config/initializers if you wish to alter milia defaults.
* the entire sample is also fully available on github, if you wish to check your work. diff can be your friend.
  this sample on github, however, will always be for the latest release or latest beta (whichever is most recent).
* find it at: https://github.com/dsaronin/sample-milia-app

### Available docmentation resources for milia

* doc/sample.sh -- this document will ALWAYS be the most recent
    (for example in the edge branch: "newdev")
* github.com/milia/wiki/sample-milia-app-tutorial
    this should be the same as the sample.sh doc for the current
    stable release (or last beta version); but markdown formatted
    https://github.com/dsaronin/milia/wiki/sample-milia-app-tutorial
* milia README (this document):
    - this will be the knowledgable programmer's digest of the essentials
    - and thus it won't cover some of the intricacies of actually
      implementing milia: either the tutorial or sample.sh will do that
    - if you're a first time milia implementer, please use both the 
      README and either of the two above documents for assistance: it will save you time.


### WARNING: don't go commando and try to change everything at once!
### WARNING: don't go perfectionist and try to bring up a fully written app at once!

Just follow the instructions, exactly, step-by-step. Get the basics working. Then change, adapt, and spice to taste.
Please?! Because I'm more inclined to help you solve problems if you've started out by 
getting the sample working exactly as described! If you've tried to go off into the jungle on your own, you are, well, on
your own. And as they say, _"get out the way you got in!"_

## converting an existing app to multi-tenanted

It is doable, but you'll need to first understand how milia basically is installed. I'd still recommend 
bringing up the sample-milia-app, getting it working, and then figuring out how to either graft it onto your app.
Or (recommended), grafting your app onto it. I prefer to work that way because it's based off of a pure Rails 4.0
and devise 3.2 install.

## Dependency requirements

* Rails 4.0.x
* Devise 3.2.x

## this readme is for v1.0.0-beta-2

* changes in beta-2: invite_member capability

* coming soon (beta-3): improved generators getting a new app started

## edge branch: "newdev"

## Authorized Roles

Milia doesn't have any requirements re roles for users. But you will probably need
something in your app to support different roles levels. Devise recommends cancan, but
I have not used it and do not know how it might affect milia. In my app, I used to use
ACL9 before it encountered version issues with Rails. Rather than debugging it, I spun
off my own simplified version which I use now with great success. The gem I wrote is
open sourced. It is called _kibali_ and is available at github: https://github.com/dsaronin/kibali. 
Kibali is a simple replacement for ACL9, a role-based authentication gem. 
I prefer the non-obstrusive nature of kibali and the clear-cut way it deliniates
roles for actions at the start of each controller. This simplicity was also in ACL9.
Kibali is primarily oriented for functioning as a before_action role authentication scheme for Rails controllers.

## Structure

* necessary models: user, tenant
* necessary migrations: user, tenant, tenants_users (join table)

You must understand which of your apps models will be tenanted ( <i>acts_as_tenant</i> ) 
and which will be universal ( <i>cts_as_universal</i>). Universal data NEVER has critical user/company
information in the table. It is usually only for system-wide constants. For example, if you've put
too much user information in the users table, you'll need to seperate it out. by definition, the devise 
user table MUST be universal and should only contain email, encrypted password, and devise-required data.
ALL OTHER USER DATA (name, phone, address, etc) should be broken out into a tenanted table (say called member_data)
which belongs_to :user, and in the User model, has_one :member_data. Ditto for organization (account or company)
information.

Most of your tables (except for pure join tables, users, and tenants) SHOULD BE tenanted. You should rarely have
universal tables, even for things you consider to be system settings. At some time in the future, your accounts
(organizations) will want to tailor/customize this data. So might as well start off correctly by making the
table tenanted. It costs you nothing to do so now at the beginning. It does mean that you will need to seed 
these tables whenever a new tenant (organizational account) is created.

Finally: 

* tenants = organizational accounts and are created via sign up, a one-time event. this also creates the 
first MEMBER of that account in your app who is usually the organizing admin. This person can then issue
invitations (below) to bring other members into the account on the app.
* members = members WITHIN a tenant and are created by invitation only; they do NOT sign up. An invitation is
sent to them, they click on an activate or confirm link, and then they become a member of a tenanted group.
* The invitation process involves creating both a new user (within the current_tenant) and its corresponding
member_data records.
* ALL models (whether tenanted or universal) are expected to have a field in the table labelled: tenant_id.
* YOUR CODE SHOULD NEVER EVER TRY TO CHANGE OR SET THE tenant_id OF A RECORD. milia will not allow it, milia
will check for deviance; milia will raise exceptions if it's wrong; and milia will override it to maintain integrity.
* Tenanted records will have tenant_id set to the appropriate tenant automagically by milia.
* Universal records will have tenant_id always set to nil, automagically by milia; and references to any
universal table will ALWAYS expect this field to be nil.
* Pure join tables (has_and_belongs_to_many HABTM associations) get neither designation (tenant nor universal).
The way that rails accesses these ensures that it will validate the tenant of joined member. A pure HABTM join
table is created with generation such as follows:

```
  rails g migration CreateModel1sModel2sJoinTable model1s model2s
```



## Installation

Either install the gem manually:

```
  $ gem install milia
```

Or in the Gemfile:

```ruby
  gem 'milia', '~>1.0'
```

If you'll be working with any beta or leading edge version:

```
   gem 'milia', :git => 'git://github.com/dsaronin/milia.git', :branch => 'v1.0.0-beta-2'
```
  
## Getting started

### Rails setup

Milia expects a user session, so please set one up. Rails 4 now
handles this with a gem, so edit your Gemfile to include:

```
  gem 'activerecord-session_store', github: 'rails/activerecord-session_store'
```

Then run BUNDLE install to get the new gems

```
  $ bundle install
```

Now generate the session migration

``` 
  $ rails g active_record:session_migration
```

### Devise setup

* See https://github.com/plataformatec/devise for how to set up devise.
* The current version of milia requires that devise use a *User* model.

Here are my recommendations for working with devise and milia:

Start the devise generation:

```
  $ rails g devise:install
  $ rails g devise user
```

Add the following in <i>config/routes.rb</i> to the existing devise_for :users  :

```
  as :user do   #   *MUST* come *BEFORE* devise's definitions (below)
    match '/user/confirmation' => 'milia/confirmations#update', :via => :put, :as => :update_user_confirmation
  end

  devise_for :users, :controllers => { 
    :registrations => "milia/registrations",
    :confirmations => "milia/confirmations",
    :sessions => "milia/sessions", 
    :passwords => "milia/passwords", 
  }

```

Add the appropriate line below to <i>config/environments/</i>_ 
files <i>development.rb, production.rb, test.rb</i>_ (respectively below, editing hosts as appropriate for your app).
Make sure you've also correctly set up the ActionMailer::Base.smtp_settings. If you're unclear as to how to 
do that, refer to the sample-milia-app.

```
  config.action_mailer.default_url_options = { :host => 'localhost:3000' }
  config.action_mailer.default_url_options = { :host => 'secure.simple-milia-app.com', :protocol => 'https' }
  config.action_mailer.default_url_options = { :host => "www.example.com" }
```

EDIT: <i>db/migrate/xxxxxxx_devise_create_users.rb</i>
and uncomment the confirmable section, it will then look as follows:

```
      ## Confirmable
      t.string   :confirmation_token
      t.datetime :confirmed_at
      t.datetime :confirmation_sent_at
      t.string   :unconfirmed_email # Only if using reconfirmable
```

and uncomment the confirmation_token index line to look as follows

```
    add_index :users, :confirmation_token,   :unique => true
```

and add above the t.timestamps line:

```
      # milia member_invitable
      t.boolean    :skip_confirm_change_password, :default => false

      t.references :tenant
```

edit <i>config/initializers/devise.rb</i> 
and change mailer_sender to be your from: email address

```
  config.mailer_sender = "my-email@simple-milia-app.com"
```

OPTIONAL (not required for milia): 
in the same initializer file, locate and uncomment the following lines:

```
  config.pepper = '46f2....'
  config.confirmation_keys = [ :email ]
  config.email_regexp = /\A[^@]+@[^@]+\z/
```

### Milia setup

#### migrations

*ALL* models require a tenanting field, whether they are to be universal or to
be tenanted. So make sure the following is added to each migration:

<i>db/migrate/xxxxxxx_create_modelXYZ.rb</i>

```
  t.references :tenant
```

Tenanted models will also require indexes for the tenant field.

```
  add_index :<tablename>, :tenant_id
```

BUT: Do not add any <i>belongs_to  :tenant</i> statements into any of your
models. milia will do that for all. I do recommend, however, that you add
into your <i>app/models/tenant.rb</i> file, one line per tenanted model such
as the following (replacing <model> with your model's name):

```
  has_many  :<model>s, :dependency => destroy
```

The reason for this is that if you wish to have a master destroy tenant action,
it will also remove all related tenanted tables and records.

Generate the tenant migration

```
  $ rails g model tenant tenant:references name:string:index
```

Generate the tenants_users join table migration

```
  $ rails g migration CreateTenantsUsersJoinTable tenants users
```

EDIT: <i>db/migrate/20131119092046_create_tenants_users_join_table.rb</i>
then uncomment the first index line as follows:

```
   t.index [:tenant_id, :user_id]
```

#### application controller

<i>app/controllers/application_controller.rb</i>
add the following line IMMEDIATELY AFTER line 4 protect_from_forgery


```
  before_action :authenticate_tenant!   # authenticate user and sets up tenant

  rescue_from ::Milia::Control::MaxTenantExceeded, :with => :max_tenants
  rescue_from ::Milia::Control::InvalidTenantAccess, :with => :invalid_tenant

# milia defines a default max_tenants, invalid_tenant exception handling
# but you can override if you wish to handle directly
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

### Clean up any generated belongs_to tenant references in all models

which the generator might have generated 
( both <i>acts_as_tenant</i> and <i>acts_as_universal</i> will specify these ).

### Designate universal models

Add the following acts_as_universal to *ALL* models which are to be universal.

```ruby
    acts_as_universal
```

### Designate tenanted models

Add the following acts_as_tenant to *ALL* models which are to be tenanted.
Example for a ficticous Post model:
  
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
  Tenant.create_new_tenant(tenant_params, coupon_params)   # see sample code below
```
  
where the sign-up params are passed, the new tenant must be validated, created,
and then returned. Any other kinds of prepatory processing are permitted here,
but should be minimal, and should not involve any tenanted models. At this point
in the new account sign-up chain, no tenant has been set up yet (but will be
immediately after the new tenant has been created).

<i>app/models/tenant.rb</i>

```ruby
  def self.create_new_tenant(tenant_params, coupon_params)

    tenant = Tenant.new(:name => tenant_params[:name])

    if new_signups_not_permitted?(coupon_params)

      raise ::Milia::Control::MaxTenantExceeded, "Sorry, new accounts not permitted at this time" 

    else 
      tenant.save    # create the tenant
    end
    return tenant
  end

  # ------------------------------------------------------------------------
  # new_signups_not_permitted? -- returns true if no further signups allowed
  # args: params from user input; might contain a special 'coupon' code
  #       used to determine whether or not to allow another signup
  # ------------------------------------------------------------------------
  def self.new_signups_not_permitted?(params)
    return false
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
      #  StartupJob.queue_startup( tenant, user, other )
      # any special seeding required for a new organizational tenant

      Member.create_org_admin(user)  # sample if using Member as tenanted member information model
  end
```

### View for Organizer sign ups

This example shows how to display a signup form together with recaptcha.
It also shows usage of an optional coupon field
for whatever reason you might need. If you're not familiar with haml, leading spaces are significant
and are used to indicate logical blocks. Otherwise, it's kinda like erb without all the syntactical cruff.
Leading "." indicate div class; "#" indicates a div ID. The example here is
taken from sample-milia-app.

<i>app/views/devise/registrations/new.html.haml</i>

```ruby
%h1 Simple Milia App
.block#block-signup
  %h2 New Organizational Sign up
  .content
    %span.description
      %i
        If you're a member of an existing group in our system, 
        click the activate link in the invitation email from your organization's admin.
        You should not sign up for a new organizational account.
        %br
    .flash
      - flash.each do |type, message|
        %div{ :class => "message #{type}" }
          %p= message
    - flash.clear  # clear contents so we won't see it again

    = form_for(resource, :as => resource_name, :url => registration_path(resource_name), :html => { :class => "form" }) do |f|
      .group
        = f.label :email, :class => "label"
        = f.text_field :email, :class => "text_field"
        %span.description Ex. test@example.com
      .group
        = f.label :password, :class => "label"
        = f.password_field :password, :class => "text_field"
        %span.description must be at least 6 characters
      .group
        = f.label :password_confirmation, "Re-enter Password", :class => "label"
        = f.password_field :password_confirmation, :class => "text_field"
        %span.description to confirm your password

      .group
        = fields_for( :tenant ) do |w|
          = w.label( :name, 'Organization', :class => "label" ) 
          = w.text_field( :name, :class => "text_field")
          %span.description unique name for your group or organization for the new account

        - if ::Milia.use_coupon
          .group
            = label_tag( 'coupon', 'Coupon code', :class => "label" )
            = text_field_tag( "coupon[coupon]", @coupon.to_s, :size => 8, :class => "text_field" )
            %span.description optional promotional code, if any

        - if ::Milia.use_recaptcha
          = recaptcha_tags( :display => { :theme => 'clean', :tabindex => 0 } )

      .group.navform.wat-cf
        %button.button{ :type => "submit" }
          = image_tag "web-app-theme/icons/tick.png"
          Sign up 
    = render :partial => "devise/shared/links"

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

## no tenant authorization required controller actions: root_path

Any controller actions, such as the root_path page, will need to skip the tenant & user authorizations.
For example in <i>app/controllers/home_controller.rb </i> place the following near the top of the controller:

```ruby
  skip_before_action :authenticate_tenant!, :only => [ :index ]
```


## console

Note that even when running the console, ($ rails console) it will be run in 
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

## inviting additional user/members

To keep this discussion simple, we'll give the example of using class Member < Activerecord::Base
which will be a tenanted table for keeping information regarding all the members in a given
organization. The name "Member" is not a requirement of milia. But this is how you would set up an
invite_member capability. It is in this event, that you will require the line in the Tenant
post-processing hook <i>tenant_signup</i> <pre>Member.create_org_admin(user)</pre> which also
creates the Member record for the initial admin on the account.

```
  $ rails g resource member tenant:references user:references first_name:string last_name:string favorite_color:string
```

ADD to <i>app/models/tenant.rb</i>
```ruby
  has_many :members, dependent: :destroy
```

ADD to <i>app/models/user.rb</i>
```ruby
    has_one :member, :dependent => :destroy
```


EDIT <i>app/models/member.rb</i>
REMOVE belongs_to :tenant
ADD
```ruby
  acts_as_tenant

  DEFAULT_ADMIN = {
    first_name: "Admin",
    last_name:  "Please edit me"
  }

  def self.create_new_member(user, params)
    # add any other initialization for a new member
    return user.create_member( params )
  end

  def self.create_org_admin(user)
    new_member = create_new_member(user, DEFAULT_ADMIN)
    unless new_member.errors.empty?
      raise ArgumentError, new_member.errors.full_messages.uniq.join(", ")
    end

    return new_member
      
  end
```

CREATE a form for inputting new member information for an invite
(below is a sample only)
<i>app/views/members/new.html.haml</i>
```ruby
%h1 Simple Milia App
.block#block-signup
  %h2 Invite a new member into #{@org_name}
  .content.login
    .flash
      - flash.each do |type, message|
        %div{ :class => "message #{type}" }
          %p= message
    - flash.clear  # clear contents so we won't see it again

    = form_for(@member, :html => { :class => "form login" }) do |f|
      - unless @member.errors.empty? && @user.errors.empty?
        #errorExplanation.group
          %ul
            = @member.errors.full_messages.uniq.inject(''){|str, msg| (str << "<li> #{msg}") }.html_safe
            = @user.errors.full_messages.uniq.inject(''){|str, msg| (str << "<li> #{msg}") }.html_safe

      = fields_for( :user ) do |w|
        .group
          = w.label :email, :class => "label "
          = w.text_field :email, :class => "text_field"
          %span.description Ex. test@example.com; must be unique

      .group
        = f.label :first_name, :class => "label "
        = f.text_field :first_name, :class => "text_field"

      .group
        = f.label :last_name, :class => "label "
        = f.text_field :last_name, :class => "text_field"

      .group
        = f.label :favorite_color, :class => "label "
        = f.text_field :favorite_color, :class => "text_field"
        %span.description What is your favorite color?

      .group.navform.wat-cf
        %button.button{ :type => "submit" }
          = image_tag "web-app-theme/icons/key.png"
          Create user and invite
```

## authorized tenanted user landing page:

You will need a members-only landing page for after someone successfully signs into your app.
Here is what I typically do:

```ruby
# REPLACE the empty def index ... end with following ADD:
# this will give you improved handling for letting user know
# what is expected. If you want to have a welcome page for
# signed in users, uncomment the redirect_to line, etc.
  def index
    if user_signed_in?

        # was there a previous error msg carry over? make sure it shows in flasher
      flash[:notice] = flash[:error] unless flash[:error].blank?
      redirect_to(  welcome_path()  )

    else

      if flash[:notice].blank?
        flash[:notice] = "sign in if your organization has an account"
      end

    end   # if logged in .. else first time

  end

  def welcome
  end

```

## Milia API

### From controller-levels:

```ruby
  set_current_tenant( tenant_id )
  #  raise InvalidTenantAccess unless tenant_id is one of the current_user valid tenants
```

set_current_tenant can be used to change the current_tenanted (for example, if a member
can belong to multiple tenants and wants to switch between them). See example else in this
README. NOTE: you will normally NEVER use this. Milia does this automatically during
authorize_tenant! so you never should at the beginning of a session.

### From model-levels:
```ruby
  Tenant.current_tenant -- returns tenant object for the current tenant; nil if none

  Tenant.current_tenant_id -- returns tenant_id for the current tenant; nil if none
```

If you need to gain access to tenant object itself (say to get the name of the tenant),
then use these accessor methods.

### From background, rake, or console-level (CAUTION):

From background jobs (only at the start of the task); 
tenant can either be a tenant object or an integer tenant_id; anything else will raise
exception.  set_current_tenant -- is model-level ability to set the current tenant
NOTE: *USE WITH CAUTION* normally this should *NEVER* be done from
the models ... it is only useful and safe WHEN performed at the start
of a background job (DelayedJob#perform) or at start of rails console, or a rake task.

```ruby
  Tenant.set_current_tenant( tenant )
    raise ArgumentError, "invalid tenant object or id"
```


## Cautions

* Milia designates a default_scope for all models (both universal and tenanted). From Rails 3.2 onwards, the last designated default scope overrides any prior scopes and will invalidate multi-tenanting; so *DO NOT USE default_scope*
* Milia uses Thread.current[:tenant_id] to hold the current tenant for the existing Action request in the application.
* SQL statements executed outside the context of ActiveRecord pose a potential danger; the current milia implementation does not extend to the DB connection level and so cannot enforce tenanting at this point.
* The tenant_id of a universal model will always be forced to nil.
* The tenant_id of a tenanted model will be set to the current_tenant of the current_user upon creation.
* HABTM (has_and_belongs_to_many) associations don't have models; they shouldn't have id fields
  (setup as below) nor any field other than the joined references; they don't have a tenant_id field;
  rails will invoke the default_scope of the appropriate joined table which does have a tenant_id field.


## Further documentation
* Check out the three-part blog discussion of _Multi-tenanting Ruby on Rails Applications on Heroku_
at: http://myrailscraft.blogspot.com/2013/05/multi-tenanting-ruby-on-rails.html
* See the Milia tutorial at: http://myrailscraft.blogspot.com/2013/05/multi-tenanting-ruby-on-rails_3982.html
* see code & setup sample in test/railsapp, which is also used to run the tests.
* see milia wiki on github for a CHANGE HISTORY page.


## Contributing to milia
 
* Check out the latest master to make sure the feature hasn't been implemented or the bug hasn't been fixed yet
* Check out the issue tracker to make sure someone already hasn't requested it and/or contributed it
* Fork the project
* Start a feature/bugfix branch
* Commit and push until you are happy with your contribution
* Make sure to add tests for it. This is important so I don't break it in a future version unintentionally.
* Please try not to mess with the Rakefile, version, or history. If you want to have your own version, or is otherwise necessary, that is fine, but please isolate to its own commit so I can cherry-pick around it.

## Copyright

Copyright (c) 2013 Daudi Amani. See LICENSE.txt for further details.

