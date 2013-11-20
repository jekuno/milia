# *********************************************************************
# HOW TO SET IT UP --     sample-milia-app
# *********************************************************************
# This is a capture of everything I did to create a sample app for milia.
# There's enough brief comments for anyone to follow step-by-step.
# It is based on my dev environment which is Ubuntu 13.10 on a PC. YMMV.
#
# The "app" itself is merely a simple barebones structure to display
# an index page, require sign-in to do anything else, has a sign-up
# page for starting a new organization (ie tenant), a way to send
# invitations to other members, and a single tenanted model to prove
# that tenanting is working.
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
#    what you should type or cut&paste, is not.
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
# STEP 0 - PREREQUISITES
# *********************************************************************
# make sure you have your ssh keys gened
$ ssh-keygen

# make sure you have some basics packages on your system
$ sudo apt-get install curl git vim vim-gnome

# make sure you've set up a github account, and git globals

# Install RVM on your system; see rvm.io for more information
$ \curl -L https://get.rvm.io | bash -s stable
# do any adjustments to your .bashrc, etc files as needed

# make sure to install ruby 2.0.0
$ rvm install 2.0.0

# I have all my projects in a directory called "projectspace'
$ mkdir projectspace
$ rvm gemset create projectspace
$ echo "projectspace" > projectspace/.ruby-gemset
$ echo "2.0.0" > projectspace/.ruby-version
$ cd projectspace

# install rails (latest version)
$ gem install rails

# OPTIONAL -- get ready for heroku
# set up a heroku account at: heroku.com
# install heroku toolbelt: heroku, foreman 
$ wget -qO- https://toolbelt.heroku.com/install-ubuntu.sh | sh
$ heroku login

# set environment variable for later Procfile
export PORT=3000
export RACK_ENV=development


# *********************************************************************
# STEP 1 - CREATION OF SKELETON APP & REPOSITORY
# *********************************************************************

$ cd projectspace   # if not there already

$ rails new sample-milia-app
$ echo "sample" > sample-milia-app/.ruby-gemset
$ echo "2.0.0" > sample-milia-app/.ruby-version
$ echo "web: bundle exec thin start -R config.ru -p $PORT -e $RACK_ENV" > sample-milia-app/Procfile
$ rvm gemset create sample
$ cd sample-milia-app
$ git init
$ git add --all .
$ git commit -am 'initial commit'
$ git remote add origin git@github.com:dsaronin/sample-milia-app.git
$ git push -u origin master


# *********************************************************************
# STEP 2 - SET UP GEMFILE, BUNDLE INSTALL GEMS
# *********************************************************************
# change .gitignore to match your development environment
# I just copy my standard .gitignore from another project
$ cp ../swalapala/.gitignore .

# EDIT Gemfile >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
$ vim Gemfile

# First, comment OUT the turbolinks gem
# gem 'turbolinks'

# then, enable rubyracer in Gemfile by de-commenting
gem 'therubyracer', platforms: :ruby

# finally, ADD the following lines to Gemfile >>>>>>>>>>>>>>>>>>>>>>

ruby "2.0.0"   # heroku likes this at the head, as line 2

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
# gem 'airbrake'   # uncomment this if you will use airbrake for exception notifications

gem 'web-app-theme', :git => 'git://github.com/dsaronin/web-app-theme.git'
gem 'devise'
gem 'milia', :git => 'git://github.com/dsaronin/milia.git', :branch => 'newdev'
gem 'recaptcha', :require => "recaptcha/rails"
#<<<< ADD <<<<<<<<<<<<<<<<<

#<<<< EDIT <<<<<<<<<<<<<<<<<

# save Gemfile and exit editor
# EDIT: app/assets/javascripts/application.js >>>>>>>>>>>>>>>>>>>>>>>>
# comment out turbolinks in your Javascript manifest file 
# we won't need turbolinks for this simple sample.
//  require turbolinks to 
#<<<< EDIT <<<<<<<<<<<<<<<<<

$ bundle install

# *********************************************************************
# STEP 3 - PREP APP UI TEMPLATES & CHECK OUT DISPLAYS
# *********************************************************************
# Source for web-app-theme notes and revisions:
#  http://blog.bryanbibat.net/2011/09/24/starting-a-professional-rails-3-1-app-with-web-app-theme-devise-and-kaminari/
# *********************************************************************

# Generate home page
$ rails g controller home index
 
# remove default Rails index page
$ rm public/index.html

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
# you may see a bunch of html2haml warnings; ok to ignore

# Delete the default layout originally generated
$ rm app/views/layouts/application.html.erb

# CHECK-OUT: 
# stop, restart server
# over at the browser, refresh the page and see the theme and colors for the basic template
# and the template page should come up

# generate some sample text for the page to flesh it out
$ rails g web_app_theme:themed home --themed-type=text --theme="red" --engine=haml

$ mv app/views/home/show.html.haml app/views/home/index.html.haml

# CHECK-OUT: over at the browser, refresh the page


# STEP 4 - SIMPLE devise SET UP (pre-milia)
$ rails g devise:install
$ rails g devise user

# EDIT: config/environments/development.rb >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
# ADD: following AFTER the final config.action_xxxxx stuff >>>>>>>>>>>>>>>>>>>>>>>

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

# of course, you will want to change your domain, email user_name and password
# to match your actual values!

# EDIT: config/environments/production.rb >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
# ADD: following AFTER the final config.action_xxxxx stuff >>>>>>>>>>>>>>>>>>>>>>

  # devise says to define default url
  config.action_mailer.default_url_options = { :host => 'secure.simple-milia-app', :protocol => 'https' }

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

# this sample is showing as how it would be if your production server
# is hosted via heroku.com using the SENDGRID plugin for emailing


# EDIT: config/environments/test.rb >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
# ADD: following AFTER the final config.action_xxxxx stuff >>>>>>>>>>>>>>>>
  # devise says to define default url
  config.action_mailer.default_url_options = { :host => "www.example.com" }
#<<<<<< EDIT <<<<<<<<<<<<

# set up scopes for device
# EDIT: app/models/user.rb >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
# add confirmable to line 4; add attr_accessible to lines 7,8
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

# uncomment the following:
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
  end
#<<<< EDIT <<<<<<<<<<<<<<<<<

# if we use devise to gen the views, they'll be genned in erb and 
# a different format from the layout style we're using.
# instead, get the two files from simple-milia-app on github
# and put them in similarly names paths in your app:

# USE:  app/views/devise/sessions/new.html.haml
# USE:  app/views/devise/registrations/new.html.haml

# CHECK-OUT: 
#   http://localhost:3000/users/sign_in
# to view the sign-in form
# then click SIGN UP and view the sign-up form 

# FINISHING TOUCHES TO SIMPLE USAGE OF devise
# modigy layout so that loutout button will work:
# EDIT: app/views/layouts/application.html.haml
# line 20 replace with:
= link_to t("web-app-theme.logout", :default => "Logout"), destroy_user_session_path, :method => :delete


# EDIT: app/controllers/application_controller.rb  >>>>>>>>>>>>>>>>>>>>>
# ADD following lines immediately after line 4 protect_from_forgery ...

  before_filter :authenticate_user!

private
  
  def after_sign_out_path_for(resource_or_scope)
    scope = Devise::Mapping.find_scope!(resource_or_scope)
    send(:"new_#{scope}_session_path")
  end
#<<<< EDIT <<<<<<<<<<<<<<<<<

# EDIT: app/controllers/home_controller.rb
# ADD immediately after line 1 class HomeController 
  skip_before_filter :authenticate_user!, :only => [ :index, :new ]
#<<<< EDIT <<<<<<<<<<<<<<<<<

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

  $ bundle install
  $ rails g active_record:session_migration

# EDIT: db/migrate/xxxxxxx_devise_create_users.rb >>>>>>>>>>>>>>>>>>>>>>>>>
# add above the t.timestamps line:
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
# comment the authenticate_user! before filter we previously added in
#  before_filter :authenticate_user!

# ADD following lines immediately after that: >>>>>>>>>>>>>>>>>>>>>>>>>>
  before_filter :authenticate_tenant!   # authenticate user and setup tenant

  rescue_from ::Milia::Control::MaxTenantExceeded, :with => :max_tenants
  rescue_from ::Milia::Control::InvalidTenantAccess, :with => :invalid_tenant
#<<<<<< ADD  <<<<<<<<<<<<

# ADD following lines AFTER private >>>>>>>>>>>>>>>>>>>>>>>>>>
private

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


# ------------------------------------------------------------------------------
# ------------------------------------------------------------------------------
  def max_tenants()
    logger.info("MARKETING - New account attempted #{Time.now.to_s(:db)} - User: #{params[:user][:email]}, org: #{params[:tenant][:company]}")
    flash[:notice] = "Sorry: new accounts not permitted at this time"
      
    # uncomment if using Airbrake & airbrake gem
    #  notify_airbrake( $! )  # have airbrake report this -- requires airbrake gem
    redirect_back
  end
  
# ------------------------------------------------------------------------------
# invalid_tenant -- using wrong or bad data
# ------------------------------------------------------------------------------
  def invalid_tenant
    flash[:notice] = "wrong tenant access; sign out & try again"
    flash[:show_flash] = true
    redirect_back
  end
 
# ------------------------------------------------------------------------------
# redirect_back -- bounce client back to referring page
# ------------------------------------------------------------------------------
  def redirect_back
    redirect_to :back rescue redirect_to root_path
  end

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
    #  @coupon = coupon
    #  @eula   = Eula.get_latest.first
 end 
#<<<<<< ADD  <<<<<<<<<<<<
#<<<< EDIT <<<<<<<<<<<<<<<<<

# EDIT: config/routes.rb  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
# ADD the :controllers clause to the existing devise_for :users  :
  devise_for :users, :controllers => { :registrations => "milia/registrations" }
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

  def self.create_new_tenant(params)

    tenant = Tenant.new(:name => params[:tenant][:name])

    if new_signups_not_permitted?(params)

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

# run the migration
  $ rake db:migrate


