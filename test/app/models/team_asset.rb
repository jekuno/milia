class TeamAsset < ActiveRecord::Base
  acts_as_tenant
  
  belongs_to :member
  belongs_to :team
end
