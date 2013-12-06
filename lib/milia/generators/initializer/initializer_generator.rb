class InitializerGenerator < Rails::Generators::Base
  desc "Creates a milia initializer file in config/initializers"

  def copy_initializer_file
    copy_file 
      File.expand_path('../templates/milia-initializer.rb', __FILE__)
      "config/initializers/milia.rb"
  end

end
