class Team < ActiveRecord::Base
  acts_as_tenant
  
  has_many :team_assets
  has_many :team_members, :through => :team_assets, :source => 'author'
end
