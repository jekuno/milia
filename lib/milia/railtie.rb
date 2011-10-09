require 'milia'
require 'rails'

module Milia
  class Railtie < Rails::Railtie
    initializer :after_initialize do
      ActiveRecord.on_load(:active_record) do
        ActiveRecord::Base.send(:extend, Milia::Base)
      end
    end

    rake_tasks do
      load 'milia/tasks.rb'
    end
  end
end
