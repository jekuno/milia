require 'rails/generators/base'

module Milia
  module Generators
# *************************************************************
    
    class InstallGenerator < Rails::Generators::Base
      desc "Creates a milia initializer"

      source_root File.expand_path("../templates", __FILE__)
      
      def copy_initializer
        copy_file 'initializer.rb', 'config/initializers/milia.rb'
      end

# -------------------------------------------------------------
# -------------------------------------------------------------
      def setup_devise
        generate "devise:install"
        generate "devise", "user"
        gsub_file "app/models/user.rb", /,\s*$/, ", :confirmable,"

        migrate_user_file = find_or_fail("db/migrate/[0-9]*_devise_create_users.rb")

        uncomment_lines( migrate_user_file, /confirm/ )
        inject_into_file migrate_user_file, after: "# t.datetime :locked_at\n" do
          snippet_db_migrate_user
        end
      end

# -------------------------------------------------------------
# -------------------------------------------------------------
     def setup_milia
       unless true
         gem 'activerecord-session_store', github: 'rails/activerecord-session_store'
         run "bundle install"

         generate "controller" "home index"
         generate "active_record:session_migration"
         generate "model" "tenant tenant:references name:string:index"
         generate "migration" "CreateTenantsUsersJoinTable tenants users"

         inject_into_file "config/routes.rb", after: "# root 'welcome#index'\n" do 
           snippet_routes_root_path
         end

         inject_into_file "app/controllers/application_controller.rb",
           after: "protect_from_forgery with: :exception\n" do 
           snippet_app_ctlr_header
         end

         inject_into_class( "app/controllers/home_controller.rb", HomeController do 
            snippet_home_ctlr_header
         end

         join_file = find_or_fail("db/migrate/[0-9]*_create_tenants_users_join_table.rb")
         uncomment_lines join_file, "t.index [:tenant_id, :user_id]" 

         gsub_file "config/routes.rb", "devise_for :users"  do 
           snippet_routes_devise
         end

         inject_into_class "app/models/user.rb",
           User do 
           snippet_model_user_determines_account
         end

        snippet_model_tenant_determines_tenant
        DELETE:  belongs_to  :tenant

       end  # skip block?
     end

     def setup_milia_member
       unless true
         generate "member" "tenant:references user:references first_name:string last_name:string"
         snippet_add_member_call_to_tenant_signup
       end
     end

# -------------------------------------------------------------
# -------------------------------------------------------------

# -------------------------------------------------------------
# -------------------------------------------------------------
private
  
# -------------------------------------------------------------
# -------------------------------------------------------------
  def find_or_fail(filename )
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
      as :user do   #   *MUST* come *BEFORE* devise's definitions (below)
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

    RUBY7
  end

  def snippet_
    <<-'RUBY8'
      has_many :members, dependent: :destroy
    RUBY8
  end

  def snippet_add_member_call_to_tenant_signup
    <<-'RUBY9'
      Member.create_org_admin(user)
    RUBY9
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

    RUBY11
  end

  def snippet_fill_member_ctlr
    <<-'RUBY12'

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

    RUBY12
  end


# *************************************************************

# -------------------------------------------------------------
# -------------------------------------------------------------
  
# -------------------------------------------------------------
# -------------------------------------------------------------

    end  # class InstallGen

# *************************************************************
  end # module Gen
end # module Milia
