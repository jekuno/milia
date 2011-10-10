require 'milia'
require 'rails'

module Milia
  class Railtie < Rails::Railtie
    initializer :after_initialize do
 
        ActiveRecord::Base.send(:extend, Milia::Base)
        ActionController::Base.send(:extend, Milia::Control)
      # ActiveRecord::Base.on_load(:active_record) do
      # end
      # 
      # ActionController::Base.on_load(:action_controller) do
      # end

    end

    rake_tasks do
      load 'milia/tasks.rb'
    end
  end
end
