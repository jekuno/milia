class InstallGenerator < Rails::Generators::Base
  desc "Installs milia"

  source_root File.expand_path("../templates", __FILE__)
  
  def copy_initializer_file
    copy_file 'initializer.rb', 'config/initializers/milia.rb'
  end

end
