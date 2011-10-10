require 'milia'
require 'rails'

module Milia
  class Railtie < Rails::Railtie
    initializer :after_initialize do
      ActiveRecord.on_load(:active_record) do
        ActiveRecord::Base.send(:extend, Milia::Base)
      end
      ActionController.on_load(:action_controller) do
        ActionController::Base.send(:extend, Milia::Control)
      end
    end

    rake_tasks do
      load 'milia/tasks.rb'
    end
  end
end
