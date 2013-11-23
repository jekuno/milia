module Milia

  class User < ActiveRecord::Base

# ------------------------------------------------------------------------  
# save_and_invite_user -- saves the new user record thus inviting user
    # via devise
    # if password missing; gens a password
    # ensures email exists and that email is unique and not already in system
# ------------------------------------------------------------------------  
    def save_and_invite_user(  )
      if (
          self.email.blank?  ||
          User.first(conditions: [ "lower(email) = ?", self.email.downcase ])
        )
        self.errors.add(:email,"must be present and unique")
        status = nil
      else
        check_or_set_password()
        status = self.save && self.errors.empty?
      end

      return status
    end

  end  # class

private

# ------------------------------------------------------------------------  
# check_or_set_password -- if password missing, generates a password
# ASSUMES: Milia.use_invite_user
# ------------------------------------------------------------------------  
  def check_or_set_password( )

    if self.password.blank?
      self.password = 
        Milia::Password.generate(
          8, Password::ONE_DIGIT | Password::ONE_CASE
        )

        self.password_confirmation = self.password
    end

  end

end # module
