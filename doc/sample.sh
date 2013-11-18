# capture of everything I did to create the sample app for milia

# STEP 0 - PREREQUISITES
# make sure you have your ssh keys gened
ssh-keygen

# make sure you have some basics packages on your system
sudo apt-get install curl git vim vim-gnome

# make sure you've set up a github account, and git globals

# Install RVM on your system; see rvm.io for more information
\curl -L https://get.rvm.io | bash -s stable
# do any adjustments to your .bashrc, etc files as needed

# make sure to install ruby 2.0.0
rvm install 2.0.0

# I have all my projects in a directory called "projectspace'
mkdir projectspace
rvm gemset create projectspace
echo "projectspace" > projectspace/.ruby-gemset
echo "2.0.0" > projectspace/.ruby-version
cd projectspace

# install rails (latest version)
gem install rails

# OPTIONAL -- get ready for heroku
# set up a heroku account at: heroku.com
# install heroku toolbelt: heroku, foreman 
wget -qO- https://toolbelt.heroku.com/install-ubuntu.sh | sh
heroku login

# set environment variable for later Procfile
export PORT=3000
export RACK_ENV=development


# STEP 1 - CREATION OF SKELETON APP & REPOSITORY

cd projectspace   # if not there already

rails new sample-milia-app
echo "sample" > sample-milia-app/.ruby-gemset
echo "2.0.0" > sample-milia-app/.ruby-version
echo "web: bundle exec thin start -R config.ru -p $PORT -e $RACK_ENV" > Procfile
rvm gemset create sample
cd sample-milia-app
git init
git add --all .
git commit -am 'initial commit'
git remote add origin git@github.com:dsaronin/sample-milia-app.git
git push -u origin master


# STEP 2 - SET UP GEMFILE, BUNDLE INSTALL GEMS

# EDIT Gemfile

# enable rubyracer in Gemfile by de-commenting
gem 'therubyracer', platforms: :ruby

# ADD the following lines to Gemfile

ruby "2.0.0"

# =========================================================
# sample-milia-app specific stuff
# =========================================================
# Bundle the extra gems:
gem 'haml-rails'   
gem 'html2haml'

# stuff that heroku likes to have
gem 'thin'
gem "SystemTimer", :require => "system_timer", :platforms => :ruby_18
gem "rack-timeout"
gem 'rails_12factor'

gem 'web-app-theme', :git => 'git://github.com/dsaronin/web-app-theme.git'
gem 'devise'
gem 'milia', :git => 'git://github.com/dsaronin/milia.git', :branch => 'newdev'
gem 'recaptcha', :require => "recaptcha/rails"
#<<<< ADD <<<<<<<<<<<<<<<<<

# comment OUT the turbolinks gem
# gem 'turbolinks'
#<<<< EDIT <<<<<<<<<<<<<<<<<

# save Gemfile and exit editor

# comment out turbolinks in your Javascript manifest file 
# (usually found at app/assets/javascripts/application.js
# we won't need it for this simple sample.
//  require turbolinks to 
#<<<< EDIT <<<<<<<<<<<<<<<<<

bundle install

# STEP 3 - PREP APP UI TEMPLATES & CHECK OUT DISPLAYS
# Source for web-app-theme notes and revisions:
#  http://blog.bryanbibat.net/2011/09/24/starting-a-professional-rails-3-1-app-with-web-app-theme-devise-and-kaminari/


# EDIT the config/routes.rb
# ADD the root :to => "home#index" within the do..end block

SampleMiliaApp::Application.routes.draw do
  root :to => "home#index"
end
#<<<< EDIT <<<<<<<<<<<<<<<<<

# create the database
rake db:create

# test by starting server:
foreman start

# CHECK-OUT: then at your browser:
http://localhost:3000/

# and the template page should come up

# ******* NOW WE'LL GENERATE A THEME with web-app-theme ********
rails g web_app_theme:theme --engine=haml --theme="red" --app-name="Simple Milia App"

# Delete the default layout originally generated

rm app/views/layouts/application.html.erb

# CHECK-OUT: over at the browser, refresh the page and see the theme and colors for the basic template

# generate some sample text for the page to flesh it out
rails g web_app_theme:themed home --themed-type=text --engine=haml
mv app/views/home/show.html.haml app/views/home/index.html.haml

# CHECK-OUT: over at the browser, refresh the page


# tweaking the web-app-theme to correct for defaults
rails g web_app_theme:assets

# EDIT: app/views/layouts/application.html.haml 
# correct: 
= stylesheet_link_tag 'application'
= javascript_include_tag 'application'

# move images for buttons to correct folder
cp $(bundle show web-app-theme)/spec/dummy/public/images/* app/assets/images/web-app-theme/ -r


# STEP 4 - SIMPLE devise SET UP (pre-milia)
rails g devise:install
rails g devise user

# EDIT: config/environments/development.rb
# ADD: following AFTER the final config.action_xxxxx stuff

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

# EDIT: config/environments/production.rb
# ADD: following AFTER the final config.action_xxxxx stuff

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


# EDIT: config/environments/test.rb
# ADD: following AFTER the final config.action_xxxxx stuff
  # devise says to define default url
  config.action_mailer.default_url_options = { :host => "www.example.com" }
#<<<<<< EDIT <<<<<<<<<<<<

# IF: you will be deploying production on heroku, then
# EDIT: config/application.rb
# NOTE: please see details and cautions at: 
#       http://guides.rubyonrails.org/asset_pipeline.html
#       Section 4.1 Precompiling Assets

# uncomment the config.time_zone line and set it to your timezone
    config.time_zone = 'Pacific Time (US & Canada)'

# ADD: following AFTER the config.time_zone line
    #  For faster asset precompiles, you can partially load your application. 
    #  In that case, templates cannot see application objects or methods. 
    #  Heroku requires this to be false.
    config.assets.initialize_on_precompile = false
#<<<<<< ADD  <<<<<<<<<<<<

#<<<<<< EDIT <<<<<<<<<<<<

# set up scopes for device
# EDIT: app/models/user.rb
# add confirmable to line 4; add attr_accessible to lines 7,8
  devise :database_authenticatable, :registerable, :confirmable,
#<<<< EDIT <<<<<<<<<<<<<<<<<

# EDIT: db/migrate/xxxxxxx_devise_create_users.rb
# uncomment the confirmable section, it will then look as follows:

      ## Confirmable
      t.string   :confirmation_token
      t.datetime :confirmed_at
      t.datetime :confirmation_sent_at
      # t.string   :unconfirmed_email # Only if using reconfirmable

#<<<< EDIT <<<<<<<<<<<<<<<<<

# EDIT: config/initializers/devise.rb
# change mailer_sender to be your from: email address
  config.mailer_sender = "conjugalis@gmail.com"

# uncomment the following:
  config.pepper = '46f2....'
  config.confirmation_keys = [ :email ]
  config.email_regexp = /\A[^@]+@[^@]+\z/

#<<<< EDIT <<<<<<<<<<<<<<<<<

# run the migration
rake db:migrate

# CHECK-OUT: check things out at browser before proceeding
# stop/restart foreman
# ^c stops foreman; foreman start  restarts it; F5 refreshes the browser page

# customize login screen
# generate the sign-in/sign-out layout:

rails g web_app_theme:theme sign --layout-type=sign --theme="red" --engine=haml --app-name="Simple Milia App"

# EDIT: config/application.rb file
# change the layout for sign-in/sign-up
# be adding the following into the class .... end block

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


# EDIT: app/controllers/application_controller.rb
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

# STEP 4 - TEST devise SIGN UP, ACTIVATION, SIGN IN, SIGN OUT
# NOTE: we will later DELETE all users added in this manner BEFORE we
# install milia. Reason is because currently there is no tenanting.
# DO NOT TRY TO LATER MANUALLY ATTEMPT TO CONVERT THESE INITIAL USERS
# TO A TENANTING MODEL: it is poor software practice to do that.
# you are just testing and verifying that we've got devise up and enabled.

# CHECK-OUT: 
# sign up as a new user, 
# the log file will show that an email was sent 
# together with the activation code & URL
# copy & paste this address as-is into the browser address area & go to it to activate
# it will take you to a sign in screen; sign in
# refresh index page (to refresh the logout validity token)
# sign out
# sign in again as the user



