require 'milia'
require 'rails'

module Milia
  class Railtie < Rails::Railtie
    initializer :after_initialize do
 
        ActiveRecord::Base.send(:include, Milia::Base)
        ActionController::Base.send(:include, Milia::Control)

    end

    rake_tasks do
      load 'milia/tasks.rb'
    end
  end
end
