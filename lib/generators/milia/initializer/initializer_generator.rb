class InitializerGenerator < Rails::Generators::Base
  desc "Creates a milia initializer file in config/initializers"

  source_root File.expand_path("../templates", __FILE__)
  
  def copy_initializer_file
    copy_file 'initializer.rb', 'config/initializers/milia.rb'
  end

end
