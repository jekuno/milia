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

# enable rubyracer in Gemfile by de-commenting
gem 'therubyracer', platforms: :ruby

# add the following lines to Gemfile

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


bundle install

# STEP 3 - PREP APP UI TEMPLATES & TEST

rails g controller home index

# edit the config/routes.rb
# add the root :to => "home#index" within the do..end block

SampleMiliaApp::Application.routes.draw do
  root :to => "home#index"
end

# create the database
rake db:create

# test by starting server:
foreman start

# then at your browser:
http://localhost:3000/

# and the template page should come up

# ******* NOW WE'LL GENERATE A THEME with web-app-theme ********
rails g web_app_theme:theme --engine=haml --theme="red" --app-name="Simple Milia App"

# Delete the default layout originally generated

rm app/views/layouts/application.html.erb

# over at the browser, refresh the page and see the theme and colors for the basic template

# generate some sample text for the page to flesh it out
rails g web_app_theme:themed home --themed-type=text --engine=haml
mv app/views/home/show.html.haml app/views/home/index.html.haml

# over at the browser, refresh the page


# tweaking the web-app-theme to correct for defaults
rails g web_app_theme:assets

# correct: app/views/layouts/application.html.haml line 6 to:
= javascript_include_tag 'application'

# correct: app/assets/stylesheets/web-app-theme/basic.css
# around line 300, comment out the three lines below and
# add following instead
/*
.form .fieldWithErrors .error {
  color: red;
}
*/

.form input.text_field, .form textarea.text_area {
  width: 100%;
  border-width: 1px;
  border-style: solid;
}

.flash .message {
    -moz-border-radius: 3px;
    -webkit-border-radius: 3px;
    border-radius: 3px;
    text-align: center;
    margin: 0 auto 15px;
    color: white;
    text-shadow: 0 1px 0 rgba(0, 0, 0, 0.3);
  }
  .flash .message p {
    margin: 8px;
  }
  .flash .error, .flash .error-list, .flash .alert {
    border: 1px solid #993624;
    background: #cc4831 url("images/messages/error.png") no-repeat 10px center;
  }
  .flash .warning {
    border: 1px solid #bb9004;
    background: #f9c006 url("images/messages/warning.png") no-repeat 10px center;
  }
  .flash .notice {
    color: #28485e;
    text-shadow: 0 1px 0 rgba(255, 255, 255, 0.7);
    border: 1px solid #8a9daa;
    background: #b8d1e2 url("images/messages/notice.png") no-repeat 10px center;
  }
  .flash .error-list {
    text-align: left;
  }
  .flash .error-list h2 {
    font-size: 16px;
    text-align: center;
  }
  .flash .error-list ul {
    padding-left: 22px;
    line-height: 18px;
    list-style-type: square;
    margin-bottom: 15px;
  }


# move images for buttons to correct folder
cp $(bundle show web-app-theme)/spec/dummy/public/images/* app/assets/images/web-app-theme/ -r


