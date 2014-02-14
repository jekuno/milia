class Post < ActiveRecord::Base
  acts_as_tenant
  
  belongs_to  :member
  belongs_to  :zine
  has_one     :team, :through => :zine


  def self.get_team_posts( team_id )
#     Post.where( where_restrict_tenant(Zine, Member) )\
#         .order("members.last_name")
  end

end
