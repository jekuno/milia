[![Build Status](https://travis-ci.org/jekuno/milia.svg?branch=master)](https://travis-ci.org/jekuno/milia)

# milia

Milia is a multi-tenanting gem for Ruby on Rails applications. Milia supports Devise.

You are viewing the documentation for using milia with **Rails 5.x** applications.  
If you want to use **Rails 4.2.x** instead please switch to [the Rails 4.x branch](https://github.com/jekuno/milia/tree/rails4-support).


<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->


- [Intro](#intro)
- [Milia highlights](#milia-highlights)
- [Basic concepts](#basic-concepts)
  - [Tenants == Organizations with Users / Members](#tenants--organizations-with-users--members)
  - [Tenanted models](#tenanted-models)
  - [Universal models](#universal-models)
  - [Join tables](#join-tables)
- [Tutorials + Documentation](#tutorials--documentation)
- [Sample app](#sample-app)
- [Installation](#installation)
  - [Adding milia to a new application](#adding-milia-to-a-new-application)
  - [Add milia to an existing application](#add-milia-to-an-existing-application)
    - [Go step by Step](#go-step-by-step)
  - [Bare minimal manual setup](#bare-minimal-manual-setup)
    - [Application controller](#application-controller)
    - [Setup base models](#setup-base-models)
      - [Designate which model determines the account](#designate-which-model-determines-the-account)
      - [Designate which model determines the tenant](#designate-which-model-determines-the-tenant)
      - [Clean up tenant references](#clean-up-tenant-references)
    - [Setup your custom models](#setup-your-custom-models)
      - [Designate tenanted models](#designate-tenanted-models)
      - [Designate universal models](#designate-universal-models)
- [Role based authorization](#role-based-authorization)
- [Milia API Reference Manual](#milia-api-reference-manual)
  - [Get current tenant](#get-current-tenant)
  - [Change current tenant](#change-current-tenant)
    - [Iterate over tenants](#iterate-over-tenants)
    - [Rails Console](#rails-console)
  - [Milia callbacks](#milia-callbacks)
- [Security / Caution](#security--caution)
- [Contributing to milia](#contributing-to-milia)
  - [Testing milia](#testing-milia)
- [Changelog](#changelog)
- [License](#license)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

## Intro
* Milia is a solid choice for (SaaS) applications which are used by more than one tenant (i.e. companies or organizations) and is tailored for common use cases of multi-tenanted applications.
* Milia allows to save the data of all tenants in the same database and enforces row based separation of the tenant data.
* Milia uses the [devise gem](https://github.com/plataformatec/devise) for user authentication and registration.

## Milia highlights
* Transparent to the main application code
* Symbiotic with user authentication (supports [devise](https://github.com/plataformatec/devise) out of the box)
* Raises exceptions upon attempted illegal access
* Enforces tenanting (not allow sloppy access to all tenant records)
* Allows application flexibility upon new tenant sign-up, usage of eula information, etc
* As non-invasive (as possible) to Rails code
* Uses row-based tenanting (for [good reasons](README_DETAILS.md#row-based-vs-schema-based-tenanting))
* Uses default_scope to enforce tenanting
* **See Milia in action in the [Sample App](#sample-app)**

## Basic concepts

### Tenants == Organizations with Users / Members
A tenant is an organization with many members (users).
Initially a user creates a new organization (tenant) and becomes its first member (and usually admin).
Then he invites further members who can then login and join the tenant.
Milia ensures that users can only access data of their own tenant (organization).


### Tenanted models
Models which belong to a certain tenant (organization).  
Add <i>acts_as_tenant</i> to the model body to activate tenanting for this model.    
Most of your tables (except for pure join tables, users, and tenants) should be tenanted.
Every record of a tenanted table needs to have a `tenant_id` set. Milia takes care of this.

### Universal models
Models which aren't specific to a tenant (organization) but have system wide relevance.
Add <i>acts_as_universal</i> to the model body to mark them as universal models.  
Universal tables <i>never</i> contain critical user/company information.
The devise user table <i>must</i> be universal and should only contain email, encrypted password, and devise-required data.
All other user data (name, phone, address, etc) should be broken out into a tenanted table called `members` (`Member belongs_to :user`, `User has_one :member`).
The same applies for organization (account or company) information.
A record of a universal table must have `tenant_id` set to nil. Milia takes care of this.

### Join tables
Pure join tables (has_and_belongs_to_many HABTM associations) are neither Universal nor Tenanted.


## Tutorials + Documentation
* Up to date starting point is the README you're currently viewing.
* For more details on token authentication, exceptions, callbacks, devise setup etc. have a look at the [additional README_DETAILS](README_DETAILS.md).
* Tutorial: There's a good [Milia tutorial](http://myrailscraft.blogspot.com/2013/05/multi-tenanting-ruby-on-rails_3982.html) at myrailscraft.
* Check out the general [three-part blog post]((http://myrailscraft.blogspot.com/2013/05/multi-tenanting-ruby-on-rails.html).) about _Multi-tenanting Ruby on Rails Applications on Heroku_.


## Sample app
You can get a sample app up and running yourself using an easy, interactive RailsApp generator and an according Milia generator. If desired the generator can also prepare everything for you to push your app to **Heroku**.
The sample app uses devise with the invite_member capability (and optionally recaptcha for new account sign-ups).
It creates skeleton user, tenant and member models.

Simply follow the following steps:

```
mkdir milia-sample-app
cd milia-sample-app
rvm use ruby-2.3.1@milia-sample-app --ruby-version --create
gem install rails
rails new . -m https://raw.github.com/RailsApps/rails-composer/master/composer.rb
```

An interactive setup starts which asks you some questions.
* Choose "Build a RailsApps example application"
* Choose "rails-devise" as the example template
* Choose Template engine "HAML"
* Choose "Devise with default modules"
* Choose the other options depending on your needs

After the setup finished add to your `Gemfile`:  
`gem 'milia', github: 'jekuno/milia'`

Install milia:
`bundle install`

In `app/controllers/application_controller.rb` add the following line immediately after `protect_from_forgery`:  
`  before_action :authenticate_tenant!`

Run the following commands:
```
spring stop
rails g milia:install --org_email='mail@your-provider.de' --skip_devise_generators=true
```

* Remove lower line "before_action :authenticate_tenant!" which has been added to `app/controllers/application_controller.rb` by the milia generator.  
* Remove the lines `@extend .text-xs-center;` (if any) from the file `1st_load_framework.css.scss`.
* Remove the file `app/views/devise/registrations/new.html.erb`

Setup the database:
`rake db:drop db:create db:migrate`

Start the server:
`rails server`

Open http://127.0.0.1:3000/users/sign_up in your browser.
You're ready to go!

### Previous sample app
For your reference: An outdated milia+devise sample app can be found at https://github.com/dsaronin/sample-milia-app
and is live on Heroku: http://sample-milia.herokuapp.com  
The according instructions on how to generate this sample app can be found at [doc/sample.sh](doc/sample.sh).

There are also outdated step-by-step instructions for setting this sample app up manually at [doc/manual_sample.sh](doc/manual_sample.sh).
  - Step 1: Sample with simple devise only
  - Step 2: Add milia for complete tenanting
  - Step 3: Add invite_member capability


## Installation
### Adding milia to a new application
The quickest way:
Follow the simple instructions of the chapter [Sample App](Sample App) to generate a new app which uses devise+milia.


### Add milia to an existing application
The recommended way to add multi-tenanting with milia to an existing app
is to bring up the [Sample App](#sample-app), get it working and then graft your app onto it.
This ensures that the Rails+Devise setup works correctly.

#### Go step by Step
Don't try to change everything at once!
Don't be a perfectionist and try to bring up a fully written app at once!

Just follow the instructions for creating the sample, exactly, step-by-step.
Get the basics working. Then change, adapt, and spice to taste.


### Bare minimal manual setup
(If you generated a [Sample App](Sample App) all of the following steps have been done already.)

Add to your Gemfile:

```ruby
  gem 'milia', '~>1.3'
```

Then run the milia generator:
```
  $ bundle install
  $ rails g milia:install --org_email='<your smtp email for dev work>'
```

Note: The milia generator has an option to specify an email address to be used for sending emails for
confirmation and account activation.

For an in depth explanation of what the generator does have a look at 
[README_DETAILS](README_DETAILS.md).

Make any changes required to the generated migrations, then:
```
  $ rake db:create
  $ rake db:migrate
```

#### Application controller

<i>app/controllers/application_controller.rb</i>
add the following line IMMEDIATELY AFTER line 4 protect_from_forgery

```
  before_action :authenticate_tenant!   # authenticate user and sets up tenant

  rescue_from ::Milia::Control::MaxTenantExceeded,   :with => :max_tenants
  rescue_from ::Milia::Control::InvalidTenantAccess, :with => :invalid_tenant
```



#### Setup base models

* Necessary models: `User`, `Tenant`
* Necessary migrations: `user`, `tenant`, `tenants_users` (join table)


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
`t.index [:tenant_id, :user_id]`

*ALL* models require a tenanting field, whether they are to be universal or to
be tenanted. So make sure you have migrations for all models which add the following:

<i>db/migrate/xxxxxxx_create_model_xyz.rb</i>

```
  t.references :tenant
```

Tenanted models also require indexes for the tenant field.

```
  add_index :<tablename>, :tenant_id
```

BUT: Do not add any <i>belongs_to  :tenant</i> statements into any of your
models. milia will do that for all. However it makes sense to add
into your <i>app/models/tenant.rb</i> file one line per tenanted model
such as the following (replacing <model> with your model's name):

```
  has_many  :<model>s, dependent: :destroy
```

The reason for this is that if you wish to have a master destroy tenant action,
it will also remove all related tenanted tables and records automatically.

Do NOT add a reference to the user model such as
```
  has_many  :users, dependent: :destroy
```
because it produces errors.



##### Designate which model determines the account

Add the following acts_as_... to designate which model will be used as the key
into tenants_users to find the tenant for a given user.
Only designate one model in this manner e.g.:

<i>app/models/user.rb</i>

```ruby
  class User < ActiveRecord::Base

    acts_as_universal_and_determines_account

  end
```

##### Designate which model determines the tenant

Add `acts_as_universal_and_determines_tenant` to designate which model will be used as the
tenant model. It is this id field which designates the tenant for an entire 
group of users which exist within a single tenanted domain.
Only designate one model in this manner.

<i>app/models/tenant.rb</i>

```ruby
  class Tenant < ActiveRecord::Base
    
    acts_as_universal_and_determines_tenant
    
  end 
```

##### Clean up tenant references

Cleanu up any generated belongs_to tenant references in all models which the generator might have generated 
(both <i>acts_as_tenant</i> and <i>acts_as_universal</i>).

#### Setup your custom models
##### Designate tenanted models

Add `acts_as_tenant` to *ALL* models which are to be tenanted.
Example for a Post model:
  
<i>app/models/post.rb</i>

```ruby
  class Post < ActiveRecord::Base
    
    acts_as_tenant
  
  end
```

##### Designate universal models

Add `acts_as_universal` to *ALL* models which are to be universal.


## Role based authorization
You can use any role based authorization you like, e.g. the [rolify gem](https://github.com/RolifyCommunity/rolify)
with [cancancan](https://github.com/CanCanCommunity/cancancan), [authority](https://github.com/nathanl/authority)
or [pundit](https://github.com/elabs/pundit).



## Milia API Reference Manual

### Get current tenant
From models call `Tenant.current_tenant` or `Tenant.current_tenant_id` to get
the current tenant.

### Change current tenant
Call `set_current_tenant( tenant_id )` from controllers.
(for example, if a member can belong to multiple tenants and wants to switch between them).
NOTE: you will normally NEVER do this manually at the beginning of a session.
Milia does this automatically during `authorize_tenant!`.

From background job, migration, rake task or console you can use `Tenant.set_current_tenant(tenant)`.
`tenant` can either be a tenant object or an integer tenant_id; anything else will raise
an exception.

**Use with caution!** Normally tenants should never be changed from within models.
It is only useful and safe when performed at the start of a background job (DelayedJob#perform), rake task, migration or start of rails console.

#### Iterate over tenants
To iterate over all instances of a certain model for all tenants do the following:  
```ruby
Tenant.find_each do |tenant|
  Tenant.set_current_tenant(tenant)
  Animal.update_all alive: true
end
```

#### Rails Console
Note that even when running the console, (`rails console`) it will be run in 
multi-tenanting mode. Call `Tenant.set_current_tenant(tenant_id)` accordingly.

### Milia callbacks
In some applications, you will want to set up commonly used
variables used throughout your application, after a user and a 
tenant have been established and authenticated.
This is optional and if the callback is missing, nothing will happen.

<i>app/controllers/application_controller.rb</i>

```ruby
  def callback_authenticate_tenant
    # set_environment or whatever else you need for each valid session
  end
```


## Security / Caution
* Milia designates a default_scope for all models (both universal and tenanted). Rails merges default_scopes if you use multiple default_scope declarations in your model, see [ActiveRecord Docs](http://api.rubyonrails.org/classes/ActiveRecord/Scoping/Default/ClassMethods.html#method-i-default_scope). However by unscoping via [unscoped](http://apidock.com/rails/ActiveRecord/Scoping/Default/ClassMethods/unscoped) you can accidentally remove tenant scoping from records. Therefore we strongly recommend to **NOT USE default_scope** at all.
* Milia uses Thread.current[:tenant_id] to hold the current tenant for the existing Action request in the application.
* SQL statements executed outside the context of ActiveRecord pose a potential danger; the current milia implementation does not extend to the DB connection level and so cannot enforce tenanting at this point.
* The tenant_id of a universal model will always be forced to nil.
* The tenant_id of a tenanted model will be set to the current_tenant of the current_user upon creation.
* HABTM (has_and_belongs_to_many) associations don't have models; they shouldn't have id fields
  (setup as below) nor any field other than the joined references; they don't have a tenant_id field;
  rails will invoke the default_scope of the appropriate joined table which does have a tenant_id field.
* Your code should never try to change or set the `tenant_id` of a record manually.
   * milia will not allow it
   * milia will check for deviance
   * milia will raise exceptions if it's wrong and
   * milia will override it to maintain integrity.
* **You use milia solely at your own risk!** 
  * When working with multi-tenanted applications you handle lots of data of several organizations/companies which means a special responsibility for protecting the data as well. Do in-depth security tests prior to publishing your application.



## Contributing to milia

* Check out the latest master to make sure the feature hasn't been implemented or the bug hasn't been fixed yet
* Check out the issue tracker to make sure someone already hasn't requested it and/or contributed it
* Fork the project
* Start a feature/bugfix branch
* Commit and push until you are happy with your contribution
* Make sure to add tests for it. This is important so we don't break the feature in a future version unintentionally.
* Please try not to mess with the Rakefile, version, or history. If you want to have your own version, or is otherwise necessary, that is fine, but please isolate to its own commit so we can cherry-pick around it.

### Testing milia
For instructions on how to run and write tests for milia please consider the [README for testing](./test/README.md)

## Changelog
See [CHANGELOG.md](CHANGELOG.md)


## License
See LICENSE.txt for further details.
