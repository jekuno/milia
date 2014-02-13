class TeamAsset < ActiveRecord::Base
  acts_as_tenant
  
  belongs_to :author
  belongs_to :team
end
