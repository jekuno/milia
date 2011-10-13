class Calendar < ActiveRecord::Base
  acts_as_tenant
  
  has_many    :zines
  belongs_to  :team
end
