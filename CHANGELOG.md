## Changelog

## v1.3.x
* Rails 5.x adapted - fully compatible
* Upgrading from v1.2.0
   * Upgrade rails, devise and milia by updating your `Gemfile` to:
     ```
     gem 'rails',  '~> 5.0'
     gem 'devise', '~> 4.2'
     gem 'milia',  '~> 1.3'   
     ```
   * Follow the official upgrade instructions for Rails and Devise.
   
## v1.2.0
* Rails 4.2.x adapted
* fixes Issue #42: Redirect loop (sign up & activate with email1; trying to sign up again with email1 fails but immediately signing in with email1 caused a redirect loop).

## v1.1.x
* Rails 4.1.x adapted
* Devise 3.4.x adapted

## v1.0.x

* Rails 4.0.x adapted (changes to terms, strong_parameters, default_scope, etc)
* Devise 3.2.x adapted
* All the changes which version 0.3.x advised to be inserted in applications_controller.rb are now automatically loaded into ActionController by milia.
* that includes authenticate_tenant!
* so if you've been using an older version of milia, you'll need to remove that stuff from applications_controller!
* generators for easy install of basic rails/milia/devise
* callback after successful authenticate_tenant!
* debug & info logging and trace for troubleshooting
* improved invite_member support
* revised README instructions
