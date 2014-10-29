# *********************************************************************
# HOW TO SET IT UP --     sample-milia-app
# *********************************************************************
# This is how to get a working app using rails/milia/devise
# together with a simple but attractive web-app-theme.
# I have added generators which automate all of the steps listed in
# manual_sample.sh (if you want to see the details).
# It is based on my dev environment which is Ubuntu 13.10 on a PC. YMMV.
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
# doc/manual_sample.sh -- step-by-step instructions WITHOUT the generators.
#
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
# 1. follow everything exactly in the order given
# 2. there's non-milia related stuff if you'll be using heroku to host
#    treat this as optional, if you'd like. but at least I know it
#    works as a completed app.
# *********************************************************************

# *********************************************************************
# STEP 0 - PREREQUISITES & EXPECTED BACKGROUND PREPARATION
# *********************************************************************

# This background is what I've done on my Ubuntu dev workstation
# so if you want to follow exactly, you'll need a similar setup.
# None of this is required for milia, only to bring up this
# sample-milia-app.

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

  $ rails new sample-milia-app --skip-bundle
  $ echo "sample-milia-app" > sample-milia-app/.ruby-gemset
  $ echo "2.1.3" > sample-milia-app/.ruby-version
  $ echo "web: bundle exec thin start -R config.ru -p $PORT -e $RACK_ENV" > sample-milia-app/Procfile
  $ rvm gemset create sample-milia-app
  $ cd sample-milia-app

# change .gitignore to match your development environment
# I just copy my standard .gitignore from another project
# but you can copy mine from sample-milia-app on github.
  $ cp ../<an existing project>/.gitignore .

  $ git init
  $ git add --all .
  $ git commit -am 'initial commit'
  $ git remote add origin git@github.com:<git-user>/sample-milia-app.git
  $ git push -u origin master

# *********************************************************************
# STEP 2 - SET UP GEMFILE, BUNDLE INSTALL GEMS
# *********************************************************************

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
  gem 'devise', '~>3.2'
  gem 'milia', :git => 'git://github.com/dsaronin/milia.git', :branch => 'v1.0.0-beta-7'

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
# STEP 3 - INSTALL milia (and automatically, devise), and app framework
# *********************************************************************
  $ rails g milia:install --org_email='<your smtp email for dev work>'
  $ rails g web_app_theme:milia

# to be able to receive the confirmation & activation emails,
# you will need to complete entering in your email and smtp
# information in the following places:
#   config/environments/development.rb
#   config/environments/production.rb

# create the database
  $ rake db:create
  $ rake db:migrate

# test by starting server:
  $ foreman start

# *********************************************************************
# STEP 4 - TEST SIGN UP, ACTIVATION, SIGN IN, SIGN OUT
# *********************************************************************
# CHECK-OUT: at your browser:
  http://localhost:3000/

# sign up as a new user, 
# the log file will show that an email was sent 
# together with the activation code & URL
# and if your email/password are correct, an email should have been sent as well!
# copy & paste this address as-is into the browser address area & go to it to activate
# it will take you to a sign in screen; sign in
# REFRESH index page (to refresh the logout validity token)
# sign out
# sign in again as the user
# you will have to first sign-up, confirm, then you can invite_member
# sign-out, confirm new member, etc

# stop/restart foreman
# ^c stops foreman; foreman start  restarts it; F5 refreshes the browser page
# 
# *********************************************************************
# STEP 5 - DEPLOYING SAMPLE-MILIA-APP TO HEROKU
# *********************************************************************

#  Make sure that you've installed the heroku toolbelt, as shown in STEP 0.
#  Make sure that you've setup git repository for you app, as shown in STEP 1.
#  Open a terminal window and make sure you've cd to your project within the projectspace.
#  Make sure that you've setup your heroku credentials on your machine using
  $ heroku login

#  Create your project (we'll call it "sample-milia" in the examples here).
  $ heroku create sample-milia

#  Now setup the various add-ons we'll need:
  $ heroku addons:add sendgrid

#  Now setup any needed configurations variables
  $ heroku config:add BUNDLE_WITHOUT="development:test:linux:mac"
  $ heroku config:add RECAPTCHA_PUBLIC_KEY='<your public key>'
  $ heroku config:add RECAPTCHA_PRIVATE_KEY='<your private key>'

# edit config/initializers/secret_token.rb
# duplicate the secret_key_base line and rename it to secret_token

# edit config/environments/production.rb  line 4
# put in the correct path for the hostname, and remove the https protocol if not needed

# edit Gemfile and replace the sqlite3 line with the following:
  # Use sqlite3 as the dev/test database for Active Record
  gem 'sqlite3', :group => [:development, :test]

  # Use pg as the production database for heroku
  gem 'pg', :group => :production

# then run bundle install, and commit to the repository
  $ bundle install
  $ git commit -am 'ready for heroku deploy'; git push origin master

# now deploy to heroku
  $ git push heroku master

# now migrate the database
  $ heroku run rake db:migrate
  $ heroku restart

# go to browser and put in the correct address for your app on heroku:

  http://sample-milia.herokuapp.com

