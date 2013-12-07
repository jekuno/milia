require 'rails/generators/base'

module Milia
  module Generators

    class InstallGenerator < Rails::Generators::Base
      desc "Creates a milia initializer"

      source_root File.expand_path("../templates", __FILE__)
      
      def copy_initializer
        copy_file 'initializer.rb', 'config/initializers/milia.rb'
      end

      def setup_devise
        generate "devise:install"
        generate "devise", "user"
        gsub_file "app/models/user.rb", /,\s*$/, ", :confirmable,"
        migrate_user_file = Dir.glob("db/migrate/[0-9]*_devise_create_users.rb").first
        raise IOError, "devise db/migrate/xxxxxx_devise_create_users.rb not found" if migrate_user_file.blank? 
        uncomment_lines( migrate_user_file, /confirm/ )
        inject_into_file migrate_user_file,
          after: "# t.datetime :locked_at\n" do <<-'RUBY'
          
          # milia member_invitable
          t.boolean    :skip_confirm_change_password, :default => false
          t.references :tenant
        RUBY
      end

    end  # class InstallGen

  end # module Gen
end # module Milia
