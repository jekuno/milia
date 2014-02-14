class Zine < ActiveRecord::Base
  acts_as_tenant
  
    belongs_to  :team
    has_many    :posts
    has_many    :members, :through => :posts

end
