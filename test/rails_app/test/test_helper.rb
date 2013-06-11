ENV["RAILS_ENV"] = "test"
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'

class ActiveSupport::TestCase

  class << self
    
    def set_tenant( tenant )
      Thread.current[:tenant_id]  = tenant.id
    end
    
    def current_tenant()
      return Thread.current[:tenant_id]
    end
    
    def reset_tenant()
       Thread.current[:tenant_id]  = nil   # starting point; no tenant
    end
    
    def void_tenant()
       Thread.current[:tenant_id]  = 0   # an impossible tenant
    end
    
  end  #  anon class
  
# -----------------------------------------------------------------------------
# setup_world -- sets up test rig for three tenants, multiple users, authors, etc
# -----------------------------------------------------------------------------  
  def setup_world()
    @Q1 = DateTime.new(2011,1,1,0,0,0)
    @Q1end = DateTime.new(2011,3,31,23,59,59)
    
    @Q2 = DateTime.new(2011,4,1,0,0,0)
    @Q2end = DateTime.new(2011,6,30,23,59,59)
    
    @Q3 = DateTime.new(2011,7,1,0,0,0)
    @Q3end = DateTime.new(2011,9,30,23,59,59)
    
    @Q4 = DateTime.new(2011,10,1,0,0,0)
    @Q4end = DateTime.new(2011,12,31,23,59,59)
    
    @max_worlds = 3
    @max_teams = 2
    @max_users = 3
    
    @dates = [
      [ @Q1, @Q1end],
      [ @Q2, @Q2end],
      [ @Q3, @Q3end],
      [ @Q4, @Q4end],
    ]
    
    
      # we'll name objects for each of three worlds to be created
    @worlds = [ ]
    
    @max_worlds.times do |w|
      @teams = []
      @cals  = []
      @zines = []
      
      world = Factory(:tenant)
      @worlds << world
      ActiveSupport::TestCase.set_tenant( world )   # set the tenant
      
      @max_teams.times do |i|
        team = Factory(:team)
        @teams << team
        
        cal = Factory(:calendar, :team => team, :cal_start => @dates[i % @dates.size][0], :cal_end =>  @dates[i % @dates.size][1])
        @cals << cal
        
        @zines << Factory(:zine, :calendar => cal)

      end # calendars, teams, zines
      
      
      @max_users.times do |i|
        user = Factory(:user)
        
        if (w.zero? && i == 2) # special case for multiple tenants
          @target = user    # jemell will be in two different tenants
          setup_author_posts(@target,1,1)
        end
        
          # create extra authors w/o associated user
        @max_teams.times do |j|
          setup_author_posts(user,i,j)
          user = nil
        end
        
      end   # users, authors, posts
      
# pick a user and put in multiple tenants
      if (!@target.nil? && w == 2)   # last world
        world.users << @target    # add to current tenant users
        setup_author_posts(@target,0,0)
      end
      
    end  # setup each world
    
    @mangoland   =  @worlds[0]
    @limesublime =  @worlds[1]
    @islesmile   =  @worlds[2]

  end  # setup world for testing
# -----------------------------------------------------------------------------  
# -----------------------------------------------------------------------------  

protected
  def setup_author_posts(user,i,j)
    author = Factory(:author, :user => user)
    Factory(:team_asset, :author => author, :team => @teams[i % @max_teams])
    Factory(:post, :zine => @zines[j], :author => author)
  end


end   #  class ActiveSupport::TestCase
