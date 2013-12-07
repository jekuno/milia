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
        inject_into_file migrate_user_file,
          after: "# t.datetime :locked_at\n" do <<-'RUBY1'
          
            # milia member_invitable
            t.boolean    :skip_confirm_change_password, :default => false
            t.references :tenant
          RUBY1
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

         inject_into_file "config/routes.rb",
           after: "# root 'welcome#index'\n" do <<-'RUBY2'
            root :to => "home#index"
           RUBY2
         end

         inject_into_file "app/controllers/application_controller.rb",
           after: "protect_from_forgery with: :exception\n" do <<-'RUBY3'
            before_action :authenticate_tenant!
            
        # milia defines a default max_tenants, invalid_tenant exception handling
        # but you can override these if you wish to handle directly
      rescue_from ::Milia::Control::MaxTenantExceeded, :with => :max_tenants
      rescue_from ::Milia::Control::InvalidTenantAccess, :with => :invalid_tenant

           RUBY3
         end

         inject_into_class(
           "app/controllers/home_controller.rb", 
           HomeController do <<-'RUBY4'
            skip_before_action :authenticate_tenant!, :only => [ :index ]

           RUBY4
         end

         join_file = find_or_fail("db/migrate/[0-9]*_create_tenants_users_join_table.rb")
         uncomment_lines join_file, "t.index [:tenant_id, :user_id]" 

         gsub_file "config/routes.rb", "devise_for :users"  do <<-'RUBY5'
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







       end  # skip block?
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
  
# -------------------------------------------------------------
# -------------------------------------------------------------
  
# -------------------------------------------------------------
# -------------------------------------------------------------

    end  # class InstallGen

# *************************************************************
  end # module Gen
end # module Milia
