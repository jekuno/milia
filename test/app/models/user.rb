class User < ActiveRecord::Base
  acts_as_universal_and_determines_account
  
  # Include default devise modules. Others available are:
  # :lockable, :encryptable,  and :omniauthable
  devise :database_authenticatable, :registerable, :confirmable,
         :recoverable, :rememberable, :trackable, :validatable

  has_one  :member, :dependent => :destroy
  has_many :tenanted_members, :dependent => :destroy,
           :class_name => "Member", :foreign_key => 'user_id'


end
