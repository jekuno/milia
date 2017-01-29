## Row based vs. schema based tenanting
* Milia uses row based tenanting.
* The author used schema-based tenanting in the past but found it deficient for the following reasons. Schema-based tenancy
  * is not what DBMS are optimized for (most DBMS are optimized to handle enormous number of rows but not an enormous number of schema (tables)),
  * took a performance hit,
  * was seriously time-consuming to backup and restore,
  * was invasive into the Rails code structure (monkey patching),
  * was complex to implement, and
  * couldn't use Rails migration tools as-is.
* Heroku also [strongly recommends against](https://devcenter.heroku.com/articles/heroku-postgresql#multiple-schemas) using schema based tenanting.



## Installation Reference Manual

This information is for reference only. The two generators automatically perform
these changes when installing the sample application. Do NOT repeat these steps
if you followed the automatic installation of the sample application.

#### information and expectations

**The above generator did everything that's required. This section
will explain why the generator did what it did. You won't need
to do any of these steps unless you decide to customize or adapt.**

#### User session required

Rails 4 now handles this with a gem:

```
  gem 'activerecord-session_store', github: 'rails/activerecord-session_store'
```

#### Generate a session migration

```
  $ rails g active_record:session_migration
```

### Devise setup

* See https://github.com/plataformatec/devise for how to set up devise.
* The current version of milia requires that devise use a *User* model.

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










## Whitelisting additional parameters for tenant/user/coupon

During the Tenant.create_new_tenant part of the sign-up process, three
sets of whitelisted parameters are passed to the method: The parameters
for tenant, user, and coupon. But some applications might require more or
other parameters than the ones expected by milia. Sometimes the application
might need to add some parameters of its own, such a EULA version number,
additions to an activation message, or a unique name for the tenant itself.

Milia has a mechanism to add additional parameters to be whitelisted. 
In <i>config/initializers/milia.rb</i> you can add a list of symbols for
the additional parameters to each of a config setting for any of the
three (tenant, user, or coupon). The example below shows how.

```ruby
  # whitelist tenant params list
  # allows an app to expand the permitted attribute list
  # specify each attribute as a symbol
  # example: [:name]
  config.whitelist_tenant_params = [:company, :cname]

  # whitelist coupon params list
  # allows an app to expand the permitted attribute list
  # specify each attribute as a symbol
  # example: [:coupon]
  config.whitelist_coupon_params = [:vendor]

```

In order to whitelist additional user params for devise `sign_in`, `sign_up` or
`account_update` you can use the default devise_parameter_sanitizer.
The milia install generator creates a file called devise_permitted_parameters.rb.
In this file you can add additional params for whitelisting.
The example below shows how:
```ruby
	def configure_permitted_parameters
		devise_parameter_sanitizer.for(:sign_up)        << [:email, :password, :password_confirmation]
		devise_parameter_sanitizer.for(:account_update) << [:email, :current_password, member_attributes: [ :first_name, :last_name]]
	end
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
  def self.create_new_tenant(tenant_params, user_params, coupon_params)

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

The milia workaround is to add an additional .where( where_restrict_tenant(klass1, klass2,...))
for each of the subordinate models in the join.

### usage of where_restrict_tenant

```ruby
    Comment.joins(stuff).where( where_restrict_tenant(Post, Author) ).all
```

## no tenant authorization required controller actions: root_path

Any controller actions, such as the root_path page, will need to skip the tenant & user authorizations.
For example in <i>app/controllers/home_controller.rb </i> place the following near the top of the controller:

```ruby
  skip_before_action :authenticate_tenant!, :only => [ :index ]
```

## using tokens for authentication

My app has certain actions which require a token for authentication, instead of a user
sign-in. These use cases include an icalendar feed for a particular user's assignments
or a generic icalendar feed for all of an organization's events. The tokens are NOT
a general replacement for user sign-in for all actions, but merely to enable a simple
restful API for certain specific actions. This section will explain how to incorporate
token authentication together with milia/devise. Please note that the application
assigns to each user an authentication token for this use, as well as creates a 
generic "guest" for the organization itself for accessing the organization-wide action.

The general scheme is to have a prepend_before_action authenticate_by_token! specified 
only for those actions allowed. This action determines the "user" required to proceed
with the action, signs in that user via devise, then falls through to the normal
before_action authenticate_tenant! action which establishes the current_tenant.

Below are some examples of this (typically the token is passed as the id parameter):

<i>app/controllers/application_controller</i>
```ruby
# ------------------------------------------------------------------------------
# NOTE: be sure to use prepend_before_action authenticate_by_token!
# so that this will occur BEFORE authenticate_tenant!
# ------------------------------------------------------------------------------
# Notice we are passing store false, so the user is not
# actually stored in the session and a token is needed for every request. 
# ------------------------------------------------------------------------------
  def authenticate_by_token!
      # special case for designated actions only
    if ( controller_name == "feeder" && 
         ( user = User.find_user_by_user_feed( params ) )
       )  ||
       ( controller_name == "questions" && ['signup_form', 'finish_signup'].include?(action_name) && 
         ( user = User.find_user_by_user_feed( params ) )
       ) 
       
        # create a special session after authorizing a user
      reset_session
      sign_in(user, store: false)  # devise's way to signin the user
      # now continue with tenant authorization & set up
      true  # ok to continue  processing
       
    else
      act_path = controller_name.to_s + '/' + action_name.to_s
      logger.info("SECURITY - access denied #{Time.now.to_s(:db)} - auth: #{params[:userfeed] }\tuid:#{(user.nil? ? 'n/f' : user.id.to_s)}\tRequest: " + act_path)
      render( :nothing => true, :status => :forbidden) #  redirect_back   # go back to where you were
      nil   # abort further processing
    end

  end

```
<i>app/controllers/feeder_controller</i>
```ruby
  prepend_before_action  :authenticate_by_token!      # special authtentication by html token
```

<i>app/models/user.rb</i>
```ruby
# ------------------------------------------------------------------------
# find_user_by_user_feed -- returns a user based on auth code from params
# ------------------------------------------------------------------------
  def self.find_user_by_user_feed( params )
      # can get auth by either :userfeed or :id
    key = ( params[:userfeed].blank? ? params[:id]  :  params[:userfeed] )
    return nil if key.blank?  # neither key present; invalid
    return User.where( :authentication_token => key ).first  # find by the key; nil if invalid
  end
  
    def make_authentication_token
      self.authentication_token = generate_unique_authentication_token
    end

  def generate_unique_authentication_token
    loop do
      token = AuthKey.make_token   # this can be anything to generate a random large token
      break token unless User.where(authentication_token: token).first
    end
  end
```





### Exceptions raised
Milia might raise the following exceptions:

```ruby
  Milia::Control::InvalidTenantAccess
  Milia::Control::MaxTenantExceeded
```
