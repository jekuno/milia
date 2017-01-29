require 'rails/generators/base'

module Milia
  module Generators
# *************************************************************

    class InstallGenerator < Rails::Generators::Base
      desc "Full installation of milia with devise"

      source_root File.expand_path("../templates", __FILE__)

      class_option :use_airbrake, :type => :boolean, :default => false, :desc => 'Use this option to add airbrake exception handling capabilities'
      class_option :skip_recaptcha, :type => :boolean, :default => true, :desc => 'Use this option to skip adding recaptcha for sign ups'
      class_option :skip_invite_member, :type => :boolean, :default => false, :desc => 'Use this option to skip adding invite_member capabilities'
      class_option :skip_env_email_setup, :type => :boolean, :default => false, :desc => 'Use this option to skip adding smtp email info to config/environments/*'
      class_option :org_email, :type => :string, :default => "my-email@my-domain.com", :desc => 'define the organizational email from address'
      class_option :skip_devise_generators, :type => :boolean, :default => false, :desc => 'skip execution of devise generators (if this has already been done previously)'

# -------------------------------------------------------------
# -------------------------------------------------------------
  def check_requirements()
    gem_find_or_fail( %w(devise) )
  end

# -------------------------------------------------------------
# -------------------------------------------------------------
  def initialize_template_variables()
    @skip_recaptcha = options.skip_recaptcha
    @skip_invite_member = options.skip_invite_member
    @use_airbrake = options.use_airbrake
  end

# -------------------------------------------------------------
# the run('bundle install') didn't work; don't know why
  # replaced it with the "run_bundle" method below
# -------------------------------------------------------------
      def setup_initial_stuff
        copy_file 'devise_permitted_parameters.rb', 'config/initializers/devise_permitted_parameters.rb'
        template 'initializer.rb', 'config/initializers/milia.rb'

         unless options.skip_recaptcha
           gem 'recaptcha', :require => "recaptcha/rails"
         end
         if options.use_airbrake
           gem 'airbrake'
         end

         gem 'activerecord-session_store', github: 'rails/activerecord-session_store'

         run_bundle
      end

# -------------------------------------------------------------
# -------------------------------------------------------------
      def setup_devise
        unless options.skip_devise_generators
          generate "devise:install"
          generate "devise", "user"
        end
        gsub_file "app/models/user.rb", /,\s*$/, ", :confirmable,"

        migrate_user_file = find_or_fail("db/migrate/[0-9]*_devise_create_users.rb")

        uncomment_lines( migrate_user_file, /confirm/ )
        inject_into_file migrate_user_file, after: "# t.datetime :locked_at\n" do
          snippet_db_migrate_user
        end

        gsub_file 'config/initializers/devise.rb', /config.mailer_sender = '.+'/, "config.mailer_sender = '#{options.org_email}'"

      end

# -------------------------------------------------------------
# -------------------------------------------------------------
     def setup_milia

       unless false    # future skip block??
         inject_into_file "app/controllers/application_controller.rb",
                          after: "protect_from_forgery with: :exception\n" do
           snippet_app_ctlr_header
         end

         route  snippet_routes_root_path

         generate "controller", "home index"
         generate "active_record:session_migration"
         generate "model", "tenant tenant:references name:string:index"
         generate "migration", "CreateTenantsUsersJoinTable tenants users"

         inject_into_class "app/controllers/home_controller.rb", HomeController do
            snippet_home_ctlr_header
         end

         join_file = find_or_fail("db/migrate/[0-9]*_create_tenants_users_join_table.rb")
         uncomment_lines join_file, ":tenant_id, :user_id"

         gsub_file "config/routes.rb", "devise_for :users"  do
           snippet_routes_devise
         end

         inject_into_file "app/models/user.rb",
           after: ":recoverable, :rememberable, :trackable, :validatable\n" do
           snippet_model_user_determines_account
         end

         gsub_file "app/models/tenant.rb", /belongs_to \:tenant/, ' '

         inject_into_class "app/models/tenant.rb", Tenant do
            snippet_model_tenant_determines_tenant
         end

       end  # skip block?
     end

     def setup_milia_member

       unless options.skip_invite_member

         generate "resource", "member tenant:references user:references first_name:string last_name:string"

         inject_into_file "app/models/tenant.rb",
           after: "acts_as_universal_and_determines_tenant\n" do
              snippet_add_assoc_to_tenant
         end

         uncomment_lines "app/models/tenant.rb", "create_org_admin"

         inject_into_file "app/models/user.rb",
           after: "acts_as_universal_and_determines_account\n" do
             snippet_add_member_assoc_to_user
         end

         gsub_file "app/models/member.rb", /belongs_to \:tenant/, ' '

         inject_into_file "app/models/member.rb",
           after: "belongs_to :user\n" do
            snippet_fill_out_member
         end

         inject_into_class "app/controllers/members_controller.rb", MembersController do
            snippet_fill_member_ctlr
         end

         directory File.expand_path('../../../../app/views/members', __FILE__), "app/views/members"
         directory File.expand_path('../../../../app/views/devise/registrations', __FILE__), "app/views/devise/registrations"


       end  # skip any member expansion
     end

# -------------------------------------------------------------
# -------------------------------------------------------------
  def setup_environments

    unless options.skip_env_email_setup

      environment nil, env: :development do
        snippet_env_dev
      end  # do dev environment

      environment nil, env: :production do
        snippet_env_prod
      end  # do production environment

      environment nil, env: :test do
        snippet_env_test
      end  # do test environment

      environment  do
        snippet_config_application
      end  # do config_application

    end
  end


# -------------------------------------------------------------
# -------------------------------------------------------------
  def wrapup()
    alert_color = :red
    say("-------------------------------------------------------------------------", alert_color)
    say("-   milia installation complete", alert_color)
    say("-   please edit your email, domain, password in config/environments/*", alert_color)
    say("-   please edit devise config/initializers/devise.rb", alert_color)
    say("-   please run migrations: $ rake db:migrate", alert_color)
    say("-------------------------------------------------------------------------", alert_color)
  end

# -------------------------------------------------------------

private

# -------------------------------------------------------------
# -------------------------------------------------------------
  def find_or_fail( filename )
    user_file = Dir.glob(filename).first
    if user_file.blank?
      say_status("error", "file: '#{filename}' not found", :red)
      raise Thor::Error, "************  terminating generator due to file error!  *************"
    end
    return user_file
  end

# -------------------------------------------------------------
# -------------------------------------------------------------

# *************************************************************
# ******  SNIPPET SECTION  ************************************
# *************************************************************
 def snippet_db_migrate_user
    <<-'RUBY1'
    
      # milia member_invitable
      t.boolean    :skip_confirm_change_password, :default => false
      t.references :tenant
    RUBY1
 end

 def snippet_routes_root_path
   <<-'RUBY2'
 root :to => "home#index"
   RUBY2
 end

 def snippet_app_ctlr_header
    <<-'RUBY3'
  before_action :authenticate_tenant!
  
     ##    milia defines a default max_tenants, invalid_tenant exception handling
     ##    but you can override these if you wish to handle directly
  rescue_from ::Milia::Control::MaxTenantExceeded, :with => :max_tenants
  rescue_from ::Milia::Control::InvalidTenantAccess, :with => :invalid_tenant

    RUBY3
 end

 def snippet_home_ctlr_header
   <<-'RUBY4'
  skip_before_action :authenticate_tenant!, :only => [ :index ]

   RUBY4
 end

 def snippet_routes_devise
<<-'RUBY5'
  
  # *MUST* come *BEFORE* devise's definitions (below)
  as :user do   
    match '/user/confirmation' => 'milia/confirmations#update', :via => :put, :as => :update_user_confirmation
  end

  devise_for :users, :controllers => { 
    :registrations => "milia/registrations",
    :confirmations => "milia/confirmations",
    :sessions => "milia/sessions", 
    :passwords => "milia/passwords", 
  }

RUBY5
  end

  def snippet_model_user_determines_account
<<-'RUBY6'

  acts_as_universal_and_determines_account

RUBY6
  end

  def snippet_model_tenant_determines_tenant
    <<-'RUBY7'

   acts_as_universal_and_determines_tenant

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
      #
      # Member.create_org_admin(user)
      #
    end

    RUBY7
  end

  def snippet_add_member_assoc_to_user
    <<-'RUBY10'
  has_one :member, :dependent => :destroy
    RUBY10
  end


  def snippet_fill_out_member
    <<-'RUBY11'
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

    RUBY11
  end

  def snippet_fill_member_ctlr
    <<-'RUBY12'

  # uncomment to ensure common layout for forms
  # layout  "sign", :only => [:new, :edit, :create]

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
    params.require(:member).permit(:first_name, :last_name)
  end

  def user_params()
    params.require(:user).permit(:email, :password, :password_confirmation)
  end

    RUBY12
  end


  def snippet_add_assoc_to_tenant
    <<-'RUBY13'
  has_many :members, dependent: :destroy
    RUBY13
  end

 def snippet_env_dev
<<-RUBY20
 
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
    :user_name => \"#{options.org_email}\",
    :password => ENV["SMTP_ENTRY"],
    :enable_starttls_auto => true
  }
RUBY20
 end

 def snippet_env_prod
<<-'RUBY21'
 
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
RUBY21
 end


 def snippet_env_test
<<-'RUBY22'
 
  # devise says to define default url
  config.action_mailer.default_url_options = { :host => "www.example.com" }
RUBY22
 end


 def snippet_config_application
<<-'RUBY23'
 
    # uncomment to ensure a common layout for devise forms
    #   config.to_prepare do   # Devise
    #     Devise::SessionsController.layout "sign"
    #     Devise::RegistrationsController.layout "sign"
    #     Devise::ConfirmationsController.layout "sign"
    #     Devise::PasswordsController.layout "sign"
    #   end   # Devise
RUBY23
 end




# *************************************************************

protected

      def bundle_command(command)
        say_status :run, "bundle #{command}"

        # We are going to shell out rather than invoking Bundler::CLI.new(command)
        # because `rails new` loads the Thor gem and on the other hand bundler uses
        # its own vendored Thor, which could be a different version. Running both
        # things in the same process is a recipe for a night with paracetamol.
        #
        # We use backticks and #print here instead of vanilla #system because it
        # is easier to silence stdout in the existing test suite this way. The
        # end-user gets the bundler commands called anyway, so no big deal.
        #
        # We unset temporary bundler variables to load proper bundler and Gemfile.
        #
        # Thanks to James Tucker for the Gem tricks involved in this call.
        _bundle_command = Gem.bin_path('bundler', 'bundle')

        require 'bundler'
        Bundler.with_clean_env do
          print `"#{Gem.ruby}" "#{_bundle_command}" #{command}`
        end
      end

      def run_bundle
        bundle_command('install') unless options[:skip_gemfile] || options[:skip_bundle] || options[:pretend]
      end

# -------------------------------------------------------------
# -------------------------------------------------------------
  def gem_find_or_fail( list )
    need_fail = false
    alert_color = :red
    list.each do |gem_name|
      gem_msg = `bundle list #{gem_name}`
      if /Could not find gem/i =~ gem_msg
        say_status(
            "error",
            "gemfile not found: #{gem_name} is required",
            alert_color
        )
        need_fail = true
      end # unless missing
    end # each constant to be checked

    if need_fail
      say("-------------------------------------------------------------------------", alert_color)
      say("-   add required gems to Gemfile; then run bundle install", alert_color)
      say("-   then retry rails g milia:install", alert_color)
      say("-------------------------------------------------------------------------", alert_color)
      raise Thor::Error, "************  terminating generator due to missing requirements!  *************"
    end  # need to fail

  end

# -------------------------------------------------------------
# -------------------------------------------------------------
  def file_find_or_fail( filename )
    user_file = Dir.glob(filename).first
    if user_file.blank?
      alert_color = :red
      say("-------------------------------------------------------------------------", alert_color)
      say_status("error", "file: '#{filename}' not found", alert_color)
      say("-   first run  $ rails g milia:install", alert_color)
      say("-   then retry $ rails g web_app_theme:milia", alert_color)
      say("-------------------------------------------------------------------------", alert_color)

      raise Thor::Error, "************  terminating generator due to file error!  *************"
    end
    return user_file
  end

# -------------------------------------------------------------
# -------------------------------------------------------------

    end  # class InstallGen

# *************************************************************
  end # module Gen
end # module Milia
