require 'rails/generators/base'

module Milia
  module Generators

    class InstallGenerator < Rails::Generators::Base
      desc "Creates a milia initializer"

      source_root File.expand_path("../templates", __FILE__)
      
      def copy_initializer
        copy_file 'initializer.rb', 'config/initializers/milia.rb'
      end

    end  # class InstallGen

  end # module Gen
end # module Milia
