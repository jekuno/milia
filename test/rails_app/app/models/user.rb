class User < ActiveRecord::Base
  acts_as_universal_and_determines_account
  has_many  :posts
  
  # Include default devise modules. Others available are:
  # :lockable, :encryptable,  and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable,
         :token_authenticatable, :confirmable, :timeoutable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me
end
