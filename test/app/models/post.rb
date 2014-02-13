class Post < ActiveRecord::Base
  acts_as_tenant
  
  belongs_to  :author
  belongs_to  :zine


  def self.get_team_posts( team_id )
    Post.joins( {:zine => :calendar}, :author)\
        .where( ["calendars.team_id = ?", team_id] )\
        .where( where_restrict_tenant(Zine, Calendar, Author) )\
        .order("authors.name")
  end

end
