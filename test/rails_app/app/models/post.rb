class Post < ActiveRecord::Base
  acts_as_tenant
  
  belongs_to  :author
  belongs_to  :zine


  def self.get_team_posts( team_id )
    Post.joins(", #{Calendar.table_name()} AS c, #{Zine.table_name()} AS z," + 
                " #{Author.table_name()} AS a")\
        .where( "#{team_id} = c.team_id AND c.id = z.calendar_id " +
                " AND #{Post.table_name}.zine_id = z.id AND #{Post.table_name}.author_id = a.id")\
        .order("a.name")    
  end



end
