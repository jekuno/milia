# *********************************************************************
# HOW TO SET IT UP --     sample-milia-app
# *********************************************************************
# 
#  NOTE: this is now an archivial copy of instructions for creating an
#  app with rails/milia/devise. After v1.0.0-beta-3, all of this is now
#  implemented using generators. But this is a reference for how to 
#  do everything manually, as of v1.1.0
# 
# *********************************************************************
# This is a capture of everything I did to create a sample app for milia.
# There's enough brief comments for anyone to follow step-by-step.
# It is based on my dev environment which is Ubuntu 14.04 on a PC. YMMV.
#
# The "app" itself is merely a simple barebones structure to display
# an index page, require sign-in to do anything else, has a sign-up
# page for starting a new organization (ie tenant), a way to send
# invitations to other members, and a single tenanted model to prove
# that tenanting is working.
#
# you can see an exact copy of the sample on github:
#   https://github.com/dsaronin/sample-milia-app
#
# *********************************************************************
# RESOURCES
# *********************************************************************
# doc/sample.sh -- this document will ALWAYS be the most recent
#   (for example in the edge branch: "newdev")
# github.com/milia/wiki/sample-milia-app-tutorial
#   this should be the same as the sample.sh doc for the current
#   stable release (or last beta version); but markdown formatted
#   https://github.com/dsaronin/milia/wiki/sample-milia-app-tutorial
# milia README:
#   this will be the knowledgable programmer's digest of the essentials
#   and thus it won't cover some of the intricacies of actually
#   implementing milia: either the tutorial or sample.sh will do that
#
# *********************************************************************
# FEEDBACK
# *********************************************************************
# If you run into difficulties while following the steps here,
# please be sure to reference the LINE NUMBER of the point at which
# had a problem, as well as any output from that step.
# BUT (caveat)
# if you've gone commando and been making changes & enhancements OR
# have been trying to roll out a full app, you're more or less on your
# own. I strongly recommend experimenting with milia first in this
# simple format, get it working, then ADD in increasing layers of
# complexity and difficulty. Trying to make too many changes at once
# is a recipe for difficulty in troubleshooting.
# *********************************************************************
# NOTES
# *********************************************************************
# Although this file has a ".sh" extension, it isn't fully executable
# as a shell script. There are just too many things you'll have to
# to do to help things along.
# 1. Instructions for you to do things are in comments;
#    things you should type or cut&paste, are not.
#    commands preceded by a "$" prompt indicate shell level command.
#    commands preceded by a ">" prompt indicate some other program command.
#    in either case, don't type the prompt as part of the command!
# 2. I've bracketed groups of text to be edited/added to a file
#    with the following style:
#    # EDIT: <path/filename> >>>>>>>>>>>>
#      things to do &/or edit or add
#    # ADD:  stuff to add follows
#      things to add
#    #<<< ADD  <<<<<<<<<<<<<<<<<<<<<<<<<<  up to here
#      maybe some more edit stuff
#    #<<< EDIT <<<<<<<<<<<<<<<<<<<<<<<<<<  up to here
# 3. follow everything exactly in the order given
# 4. there's non-milia related stuff if you'll be using heroku to host
#    treat this as optional, if you'd like. but at least I know it
#    works as a completed app.
# *********************************************************************

# *********************************************************************
# STEP 0 - PREREQUISITES & EXPECTED BACKGROUND PREPARATION
# *********************************************************************

# this background is what I've done on my Ubuntu dev workstation
# so if you want to follow exactly, you'll need similar.
# none of this is required for milia; only to exactly bring up
# this sample-milia-app.

# make sure you have your ssh keys gen'd
  $ ssh-keygen

# make sure you have some basic packages on your system
  $ sudo apt-get install curl git vim vim-gnome

# make sure you've set up a github account, and git globals

# Install RVM on your system; see rvm.io for more information
  $ \curl -L https://get.rvm.io | bash -s stable
# do any adjustments to your .bashrc, etc files as needed

# make sure to install ruby 2.1.3
  $ rvm install 2.1.3

# I have all my projects in a directory called "projectspace'
  $ mkdir projectspace
  $ rvm gemset create projectspace
  $ echo "projectspace" > projectspace/.ruby-gemset
  $ echo "2.1.3" > projectspace/.ruby-version
  $ cd projectspace

# install rails (latest version)
  $ gem install rails

# OPTIONAL -- get ready for heroku
# set up a heroku account at: heroku.com
# install heroku toolbelt: heroku, foreman 
  $ wget -qO- https://toolbelt.heroku.com/install-ubuntu.sh | sh
  $ heroku login

# set environment variable for later Procfile and later recaptcha
# I put them in .bashrc
export PORT=3000
export RACK_ENV=development
export SMTP_ENTRY=<my smtp password>
# OPTIONAL: recaptcha keys
export RECAPTCHA_PUBLIC_KEY=6LeYAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAKpT
export RECAPTCHA_PRIVATE_KEY=6LeBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBgQBv


# *********************************************************************
# STEP 1 - CREATION OF SKELETON APP & REPOSITORY
# *********************************************************************

# GITHUB: create a new repository <your-new-app> for <git-user> (you)
# anywhere below where you see "sample-milia-app", change it to <your-new-app>

  $ cd projectspace   # if not there already

  $ rails new sample-milia-app  --skip-bundle
  $ echo "sample-milia-app" > sample-milia-app/.ruby-gemset
  $ echo "2.1.3" > sample-milia-app/.ruby-version
  $ echo "web: bundle exec thin start -R config.ru -p $PORT -e $RACK_ENV" > sample-milia-app/Procfile
  $ rvm gemset create sample-milia-app
  $ cd sample-milia-app
  $ git init
  $ git add --all .
  $ git commit -am 'initial commit'
  $ git remote add origin git@github.com:<git-user>/sample-milia-app.git
  $ git push -u origin master


# *********************************************************************
# STEP 2 - SET UP GEMFILE, BUNDLE INSTALL GEMS
# *********************************************************************
# change .gitignore to match your development environment
# I just copy my standard .gitignore from another project
# but you can copy mine from sample-milia-app on github.
  $ cp ../swalapala/.gitignore .

# EDIT Gemfile >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  $ vim Gemfile

# First, comment OUT the turbolinks gem
  # gem 'turbolinks'

# then, enable rubyracer in Gemfile by de-commenting
  gem 'therubyracer', platforms: :ruby

# finally, ADD the following lines to Gemfile >>>>>>>>>>>>>>>>>>>>>>

  ruby "2.1.3"   # heroku likes this at the head, as line 2

  # =========================================================
  # sample-milia-app specific stuff
  # =========================================================
  # Bundle the extra gems:
  gem 'haml-rails'   
  gem 'html2haml', :git => 'git://github.com/haml/html2haml.git'  # "2.0.0.beta.2", 

  # stuff that heroku likes to have
  gem 'thin'
  gem "SystemTimer", :require => "system_timer", :platforms => :ruby_18
  gem "rack-timeout"
  gem 'rails_12factor'

  # airbrake is optional and configured by config.use_airbrake in milia initializer
  # default is false; if you change it to true, uncomment out the line below
  # gem 'airbrake'   # uncomment this if you will use airbrake for exception notifications

  gem 'web-app-theme', :git => 'git://github.com/dsaronin/web-app-theme.git'
  gem 'devise', '~>3.4.0'
  gem 'milia', :git => 'git://github.com/dsaronin/milia.git', :branch => 'v1.1.0'

  # recaptcha is optional and configured by config.use_recaptcha in milia initializer
  # default is true; if you change it to false, comment out the line below
  gem 'recaptcha', :require => "recaptcha/rails"
#<<<< ADD <<<<<<<<<<<<<<<<<
#<<<< EDIT <<<<<<<<<<<<<<<<<

# EDIT: app/assets/javascripts/application.js >>>>>>>>>>>>>>>>>>>>>>>>
# comment out turbolinks in your Javascript manifest file 
# we won't need turbolinks for this simple sample.
  //  require turbolinks
#<<<< EDIT <<<<<<<<<<<<<<<<<

# BUNDLE install all the gems
  $ bundle install

# *********************************************************************
# STEP 3 - PREP APP UI TEMPLATES & CHECK OUT DISPLAYS
# *********************************************************************
# Source for web-app-theme notes and revisions:
#  http://blog.bryanbibat.net/2011/09/24/starting-a-professional-rails-3-1-app-with-web-app-theme-devise-and-kaminari/
# *********************************************************************

# Generate home page
  $ rails g controller home index
 

# EDIT the config/routes.rb >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
# ADD the root :to => "home#index" within the do..end block 

    SampleMiliaApp::Application.routes.draw do

      root :to => "home#index"

    end
#<<<< EDIT <<<<<<<<<<<<<<<<<


# create the database
  $ rake db:create

# test by starting server:
  $ foreman start

# CHECK-OUT: at your browser:
  http://localhost:3000/
# you should see an empty template page for home/index


# ******* NOW WE'LL GENERATE A THEME with web-app-theme ********
  $ rails g web_app_theme:theme --engine=haml --theme="red" --app-name="Simple Milia App"

# Delete the default layout originally generated
  $ rm app/views/layouts/application.html.erb

# generate some sample text for the page to flesh it out
  $ rails g web_app_theme:themed home --themed-type=text --theme="red" --engine=haml

  $ mv app/views/home/show.html.haml app/views/home/index.html.haml


# STEP 4 - SIMPLE devise SET UP (pre-installing milia)
  $ rails g devise:install
  $ rails g devise user

# EDIT: config/environments/development.rb >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
# ADD: following AFTER the final config.action_xxxxx stuff >>>>>>>>>>>>>>>>>>>>>>>
# of course, you will want to change your domain, email user_name and password
# to match your actual values!

  # devise says to define default url
  config.action_mailer.default_url_options = { :host => 'localhost:3000' }

  # set up for email sending even in dev mode
  # Don't care if the mailer can't send
  config.action_mailer.raise_delivery_errors = false

  config.action_mailer.delivery_method = :smtp
  
  ActionMailer::Base.smtp_settings = {
    :address => "smtp.gmail.com",
    :port => "587",
    :authentication => :plain,
    :user_name => "my-email@simple-milia-app.com",
    :password => "my-password",
    :enable_starttls_auto => true
  }
#<<<<<< EDIT <<<<<<<<<<<<


# EDIT: config/environments/production.rb >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
# this sample is showing as how it would be if your production server
# is hosted via heroku.com using the SENDGRID plugin for emailing
# ADD: following AFTER the final config.action_xxxxx stuff >>>>>>>>>>>>>>>>>>>>>>

  # devise says to define default url
  config.action_mailer.default_url_options = { :host => 'secure.simple-milia-app.com', :protocol => 'https' }

  ActionMailer::Base.delivery_method = :smtp

  ActionMailer::Base.smtp_settings = {
    :address        => 'smtp.sendgrid.net',
    :port           => '587',
    :authentication => :plain,
    :user_name      => ENV['SENDGRID_USERNAME'],
    :password       => ENV['SENDGRID_PASSWORD'],
    :domain         => 'heroku.com'
  }
#<<<<<< EDIT <<<<<<<<<<<<

# EDIT: config/environments/test.rb >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
# ADD: following AFTER the final config.action_xxxxx stuff >>>>>>>>>>>>>>>>
  # devise says to define default url
  config.action_mailer.default_url_options = { :host => "www.example.com" }
#<<<<<< EDIT <<<<<<<<<<<<

# set up scopes for devise
# EDIT: app/models/user.rb >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
# add confirmable to line 4
  devise :database_authenticatable, :registerable, :confirmable,
#<<<< EDIT <<<<<<<<<<<<<<<<<

# EDIT: db/migrate/xxxxxxx_devise_create_users.rb >>>>>>>>>>>>>>>>>>>>>>>>>
# uncomment the confirmable section, it will then look as follows:

      ## Confirmable
      t.string   :confirmation_token
      t.datetime :confirmed_at
      t.datetime :confirmation_sent_at
      t.string   :unconfirmed_email # Only if using reconfirmable

# and uncomment the confirmation_token index line
    add_index :users, :confirmation_token,   :unique => true

#<<<< EDIT <<<<<<<<<<<<<<<<<

# EDIT: config/initializers/devise.rb >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
# change mailer_sender to be your from: email address
  config.mailer_sender = "my-email@simple-milia-app.com"

# locate and uncomment the following lines:
  config.pepper = '46f2....'
  config.confirmation_keys = [ :email ]
  config.email_regexp = /\A[^@]+@[^@]+\z/

#<<<< EDIT <<<<<<<<<<<<<<<<<

# run the migration
  $ rake db:migrate

# CHECK-OUT: check things out at browser before proceeding
# stop/restart foreman
# ^c stops foreman; foreman start  restarts it; F5 refreshes the browser page

# customize login screen
# generate the sign-in/sign-out layout:

  $ rails g web_app_theme:theme sign --layout-type=sign --theme="red" --engine=haml --app-name="Simple Milia App"

# EDIT: config/application.rb >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
# NOTE: please see details and cautions at: 
#       http://guides.rubyonrails.org/asset_pipeline.html
#       Section 4.1 Precompiling Assets

# uncomment the config.time_zone line and set it to your timezone
    config.time_zone = 'Pacific Time (US & Canada)'

# IF: you will be deploying production on heroku, then
# ADD: following AFTER the config.time_zone line >>>>>>>>>>>>>>>>>>>>>>>>>>>
    #  For faster asset precompiles, you can partially load your application. 
    #  In that case, templates cannot see application objects or methods. 
    #  Heroku requires this to be false.
    config.assets.initialize_on_precompile = false
#<<<<<< ADD  <<<<<<<<<<<<

# change the layout for sign-in/sign-up
# by adding the following into the class .... end block

  config.to_prepare do
    Devise::SessionsController.layout "sign"
    Devise::RegistrationsController.layout "sign"
    Devise::ConfirmationsController.layout "sign"
    Devise::PasswordsController.layout "sign"
  end
#<<<< EDIT <<<<<<<<<<<<<<<<<

# if we use devise to gen the views, they'll be genned in erb and 
# a different format from the layout style we're using.
# my web_app_theme has a generator to gen them automagically
  $ rails g web_app_theme:devise

# EDIT: app/controllers/application_controller.rb  >>>>>>>>>>>>>>>>>>>>>
# NOTE: this line is only for the basic devise (no milia) version;
# we will later uncomment or remove this line when we install milia
# ADD following lines immediately after line 4 protect_from_forgery ...
  before_action :authenticate_user!
#<<<< EDIT <<<<<<<<<<<<<<<<<

# EDIT: app/controllers/home_controller.rb
# ADD immediately after line 1 class HomeController 
  skip_before_action :authenticate_user!, :only => [ :index ]
#<<<< EDIT <<<<<<<<<<<<<<<<<

# CHECK-OUT: 
#   http://localhost:3000/users/sign_in
# to view the sign-in form
# then click SIGN UP and view the sign-up form 

# *********************************************************************
# STEP 4 - TEST devise SIGN UP, ACTIVATION, SIGN IN, SIGN OUT
# *********************************************************************
# NOTE: we will later DELETE all users added in this manner BEFORE we
# install milia. Reason is because currently there is no tenanting.
# DO NOT TRY TO LATER MANUALLY ATTEMPT TO CONVERT THESE INITIAL USERS
# TO A TENANTING MODEL: it is poor software practice to do that.
# you are just testing and verifying that we've got devise up and enabled.
# *********************************************************************

# CHECK-OUT: 
# sign up as a new user, 
# the log file will show that an email was sent 
# together with the activation code & URL
# and if your email/password are correct, an email should have been sent as well!
# copy & paste this address as-is into the browser address area & go to it to activate
# it will take you to a sign in screen; sign in
# REFRESH index page (to refresh the logout validity token)
# sign out
# sign in again as the user

# *********************************************************************
# STEP 5 - adding in milia and making multi-tenantable
# *********************************************************************
# remove any users created above in STEP 4
# start the rails console
  $ rail c
    > User.all.each{|x| x.destroy}
    > exit

# rollback the initial migration (because we'll be changing it slightly)
  $ rake db:rollback

# Milia expects a user session, so please set one up
# EDIT: Gemfile
# ADD
  gem 'activerecord-session_store', github: 'rails/activerecord-session_store'
#<<<< EDIT <<<<<<<<<<<<<<<<<

# BUNDLE install to get the new gems
  $ bundle install

# now generate the session migration
  $ rails g active_record:session_migration

# EDIT: db/migrate/xxxxxxx_devise_create_users.rb >>>>>>>>>>>>>>>>>>>>>>>>>
# add above the t.timestamps line:
      # milia member_invitable
      t.boolean    :skip_confirm_change_password, :default => false

      t.references :tenant
#<<<< EDIT <<<<<<<<<<<<<<<<<

# generate the tenant migration
  $ rails g model tenant tenant:references name:string:index

# generate the tenants_users join table migration
  $ rails g migration CreateTenantsUsersJoinTable tenants users

# EDIT: db/migrate/20131119092046_create_tenants_users_join_table.rb >>>>>>>>>>
# then uncomment the first index line as follows:
      t.index [:tenant_id, :user_id]
#<<<< EDIT <<<<<<<<<<<<<<<<<

# EDIT: app/controllers/application_controller.rb  >>>>>>>>>>>>>>>>>>>>>
# NOTE: before all tenanted controllers,  you MUST HAVE a 
#     before_action :authenticate_tenant!
# It is best to have it at the start of your application_controller
# If you happen to have any general universal access controllers,
# then you can place at the top of those specific controllers:
#     skip_before_action :authenticate_tenant!, :only => [ <action name>  ]
#
# CHANGE: comment authenticate_user! line to authenticate_tenant!
# (make it look like the statement below)
  before_action :authenticate_tenant!   # authenticates user and sets up tenant

# ADD following lines immediately after that: >>>>>>>>>>>>>>>>>>>>>>>>>>

  rescue_from ::Milia::Control::MaxTenantExceeded, :with => :max_tenants
  rescue_from ::Milia::Control::InvalidTenantAccess, :with => :invalid_tenant
# milia defines a default max_tenants, invalid_tenant exception handling
# but you can override if you wish to handle directly
#<<<<<< ADD  <<<<<<<<<<<<

#<<<< EDIT <<<<<<<<<<<<<<<<<

# EDIT: config/routes.rb  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
# ADD the :controllers clause to the existing devise_for :users  :

  as :user do   #   *MUST* come *BEFORE* devise's definitions (below)
    match '/user/confirmation' => 'milia/confirmations#update', :via => :put, :as => :update_user_confirmation
  end

  devise_for :users, :controllers => { 
    :registrations => "milia/registrations",
    :confirmations => "milia/confirmations",
    :sessions => "milia/sessions", 
    :passwords => "milia/passwords", 
  }

#<<<< EDIT <<<<<<<<<<<<<<<<<

# EDIT: app/models/user.rb >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
# ADD after the class User line:
    acts_as_universal_and_determines_account
#<<<< EDIT <<<<<<<<<<<<<<<<<


# EDIT: app/models/tenant.rb >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
# DELETE
  belongs_to  :tenant

# ADD after the class Tenant line: >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
    acts_as_universal_and_determines_tenant

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
    end
#<<<<<< ADD  <<<<<<<<<<<<

#<<<< EDIT <<<<<<<<<<<<<<<<<

# EDIT: app/controllers/home_controller.rb
# CHANGE skip_authenticate_user! to skip_authenticate_tenant!
  skip_before_action :authenticate_tenant!, :only => [ :index ]

# REPLACE the empty def index ... end with following ADD:
# this will give you improved handling for letting user know
# what is expected. If you want to have a welcome page for
# signed in users, uncomment the redirect_to line, etc.
  def index
    if user_signed_in?

        # was there a previous error msg carry over? make sure it shows in flasher
      flash[:notice] = flash[:error] unless flash[:error].blank?
      #   redirect_to(  welcome_path()  )

    else

      if flash[:notice].blank?
        flash[:notice] = "sign in if your organization has an account"
      end

    end   # if logged in .. else first time

  end
#<<<< ADD  <<<<<<<<<<<<<<<<<
#<<<< EDIT <<<<<<<<<<<<<<<<<

# run the migration
  $ rake db:migrate

# config/initializers/milia.rb now supported for config parameters
# OPTIONAL: change milia configuration options
# copy doc/milia-initializer.rb to config/initializers/
# then edit values as appropriate

# NOTE: if Milia.use_coupon is true (default configuration option), 
# then your sign up form MUST return a parameter 
#     :coupon => { :coupon => <string> } 
# which can also be blank.

# OPTIONAL: edit config/application.rb and add the following to alter
# default behavior for handling strong_parameters in Rails
# see: https://github.com/rails/strong_parameters#handling-of-unpermitted-keys
# choose one of the two options: :raise OR :log
 ActionController::Parameters.action_on_unpermitted_parameters = :raise | :log

# CHECK-OUT: restart foreman and check out at your browser:
  http://localhost:3000/
# click sign up to sign up a new account, get confirmation email (or view in log)
# activate the new account, sign in, sign out, etc.


# *********************************************************************
# STEP 6 - adding a tenanted members table, then inviting a member
# *********************************************************************
# remove any users, and tenants created above in STEP 5
# start the rails console
  $ rails c
    > User.all.each{|x| x.destroy}
    > Tenant.all.each{|x| x.destroy}
    > exit


  $ rails g resource member tenant:references user:references first_name:string last_name:string favorite_color:string

# ADD to app/models/tenant.rb
  has_many :members, dependent: :destroy

# EDIT self.tenant_signup method
  # ------------------------------------------------------------------------
    def self.tenant_signup(user, tenant, other = nil)
      #  StartupJob.queue_startup( tenant, user, other )
      # any special seeding required for a new organizational tenant

      Member.create_org_admin(user)
    end


# EDIT app/models/user.rb >>>>>>>>>>>>>>>>>>>>
# ADD
    has_one :member, :dependent => :destroy
#<<<< EDIT <<<<<<<<<<<<<<<<<



# EDIT app/models/member.rb
# REMOVE belongs_to :tenant
# ADD
  acts_as_tenant

  DEFAULT_ADMIN = {
    first_name: "Admin",
    last_name:  "Please edit me",
    favorite_color: "blue"
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


# EDIT:  app/views/members/new.html.haml >>>>>>>>>>>>>>>>>>>>>>>>>>>>
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
#<<<< ADD  <<<<<<<<<<<<<<<<<
#<<<< EDIT <<<<<<<<<<<<<<<<<

# EDIT app/controllers/application_controller.rb
# ADD:
  before_action  :prep_org_name

private

# org_name will be passed to layout & view
  def prep_org_name()
    @org_name = ( user_signed_in?  ?
      Tenant.current_tenant.name  :
      "Simple Milia App"
    )

  end

# EDIT app/views/layouts/application.rb >>>>>>>>>>>>>>>>>>>>
# the following is not a requirement, but serves to show
# how to handle tenanted sign ins and welcome pages
# replaces the two instances of "Simple Milia App" with 
# (everything bewtween the quotes but not including the quotes):
# "= @org_name", make the results look like the two lines below

  %title= @org_name

  = link_to @org_name, "/"

# make changes to layout for invite member; change the portion 
# with the "sign_up" link to look like the following:
              %li
                - if user_signed_in?
                  = link_to t("web-app-theme.invite", :default => "Invite member"), new_member_path
                - else
                  = link_to( t("web-app-theme.signup", :default => "Sign up"), new_user_registration_path )

#<<<< EDIT <<<<<<<<<<<<<<<<<

# EDIT: app/controllers/members_controller.rb >>>>>>>>>>>>>>>>>>>>>>>>>>>>>

# ADD after the class line: >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

  layout  "sign", :only => [:new, :edit, :create]

  def new()
    @member = Member.new()
    @user   = User.new()
  end

  def create()
    @user   = User.new( user_params )

    # ok to create user, member
    if @user.save_and_invite_member() && @user.create_member( member_params )
      flash[:notice] = "New member added and invitation email sent to #{@user.email}."
      redirect_to root_path
    else
      flash[:error] = "errors occurred!"
      @member = Member.new( member_params ) # only used if need to revisit form
      render :new
    end

  end


  private

  def member_params()
    params.require(:member).permit(:first_name, :last_name, :favorite_color)
  end

  def user_params()
    params.require(:user).permit(:email, :password, :password_confirmation)
  end

#<<<< ADD  <<<<<<<<<<<<<<<<<
#<<<< EDIT <<<<<<<<<<<<<<<<<


# run the migration
  $ rake db:migrate

# CHECK-OUT: check things out at browser before proceeding
# stop/restart foreman
# you will have to first sign-up, confirm, then you can invite_member
# sign-out, confirm new member, etc

# MILIA API EXPLAINED: Tenant.current_tenant, etc

# from controller-level:

  set_current_tenant( tenant_id )
    raise InvalidTenantAccess unless tenant_id is one of the current_user valid tenants

# from model-level:
  Tenant.current_tenant -- return tenant object for the current tenant; nil if none

  Tenant.current_tenant_id -- returns tenant_id for the current tenant; nil if none

# from background job s (only at the start of the task); 
# tenant can either be a tenant object or an integer tenant_id; anything else will raise
# exception
# set_current_tenant -- model-level ability to set the current tenant
# NOTE: *USE WITH CAUTION* normally this should *NEVER* be done from
# the models ... it is only useful and safe WHEN performed at the start
# of a background job (DelayedJob#perform)

  Tenant.set_current_tenant( tenant )
    raise ArgumentError, "invalid tenant object or id"

