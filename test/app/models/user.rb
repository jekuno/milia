class User < ActiveRecord::Base
  acts_as_universal_and_determines_account
  has_one :author
  has_many :posts, :through => :author, :source => 'posts'
  
  # Include default devise modules. Others available are:
  # :lockable, :encryptable,  and :omniauthable
  devise :database_authenticatable, :registerable, :confirmable,
         :recoverable, :rememberable, :trackable, :validatable

  has_one :member, :dependent => :destroy

end
