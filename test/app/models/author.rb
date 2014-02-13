class Author < ActiveRecord::Base
  acts_as_tenant

  belongs_to :user
  has_many  :posts
  has_many :team_assets
  has_many :teams, :through => :team_assets, :source => 'team'
    
end
