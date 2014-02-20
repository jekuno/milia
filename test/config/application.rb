require File.expand_path('../boot', __FILE__)

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(:default, Rails.env)

module Miliatest
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.
    # uncomment to ensure a common layout for devise forms

    config.to_prepare do   # Devise
    Devise::SessionsController.layout "sign"
    Devise::RegistrationsController.layout "sign"
    Devise::ConfirmationsController.layout "sign"
    Devise::PasswordsController.layout "sign"
    end   # Devise

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    config.time_zone = 'Pacific Time (US & Canada)'

    #  if you want to skip the locale validation or don't care about locales
    #  set this to false
    config.i18n.enforce_available_locales = false


    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de
  end
end
