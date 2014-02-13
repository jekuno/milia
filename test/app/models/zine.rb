class Zine < ActiveRecord::Base
  acts_as_tenant
  
  belongs_to  :calendar
  has_many    :posts
end
