require 'rails/generators/base'

module Milia
  module Generators
# *************************************************************
    
    class TempGenerator < Rails::Generators::Base
      desc "Temp for debugging/testing"

      source_root File.expand_path("../templates", __FILE__)
  
# -------------------------------------------------------------
# -------------------------------------------------------------
# -------------------------------------------------------------
# -------------------------------------------------------------
# -------------------------------------------------------------
# -------------------------------------------------------------
# -------------------------------------------------------------

# -------------------------------------------------------------
# -------------------------------------------------------------
  def wrapup()
    alert_color = :red
    say("----------------------------------------------------------------------", alert_color)
    say("-   milia installation complete", alert_color)
    say("-   please edit your email, domain, password in config/environments", alert_color)
    say("-   please run migrations: $ rake db:migrate", alert_color)
    say("----------------------------------------------------------------------", alert_color)
  end

# -------------------------------------------------------------
# -------------------------------------------------------------
# -------------------------------------------------------------

private

# -------------------------------------------------------------
# -------------------------------------------------------------
  def find_or_fail( filename )
    user_file = Dir.glob(filename).first
    if user_file.blank? 
      say_status("error", "file: '#{filename}' not found", :red)
      raise Thor::Error, "************  terminating generator due to file error!  *************" 
    end
    return user_file
  end
  
# -------------------------------------------------------------
# -------------------------------------------------------------

# *************************************************************

protected

      def bundle_command(command)
        say_status :run, "bundle #{command}"

        # We are going to shell out rather than invoking Bundler::CLI.new(command)
        # because `rails new` loads the Thor gem and on the other hand bundler uses
        # its own vendored Thor, which could be a different version. Running both
        # things in the same process is a recipe for a night with paracetamol.
        #
        # We use backticks and #print here instead of vanilla #system because it
        # is easier to silence stdout in the existing test suite this way. The
        # end-user gets the bundler commands called anyway, so no big deal.
        #
        # We unset temporary bundler variables to load proper bundler and Gemfile.
        #
        # Thanks to James Tucker for the Gem tricks involved in this call.
        _bundle_command = Gem.bin_path('bundler', 'bundle')

        require 'bundler'
        Bundler.with_clean_env do
          print `"#{Gem.ruby}" "#{_bundle_command}" #{command}`
        end
      end

      def run_bundle
        bundle_command('install') unless options[:skip_gemfile] || options[:skip_bundle] || options[:pretend]
      end


# -------------------------------------------------------------
# -------------------------------------------------------------
  
# -------------------------------------------------------------
# -------------------------------------------------------------

    end  # class TempGen

# *************************************************************
  end # module Gen
end # module Milia
