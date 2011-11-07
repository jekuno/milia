FactoryGirl.define do |binding|
  
  Thread.current[:tenant_id] = nil  # reset at start
  
# #############################################################################
# ************* HELPER METHODS FOR THIS FACTORY *******************************
# #############################################################################
  class << binding
    
    # current_tenant -- create or work within a default tenant
    def current_tenant()
      Thread.current[:tenant_id] ||= Factory(:tenant).id
    end
    
    # new_tenant -- switch over to a new tenant to be the default tenant
    def new_tenant()
      Thread.current[:tenant_id] = Factory(:tenant).id
    end

    USERNAMES = %w(demarcus deshaun jemell jermaine jabari kwashaun musa nigel kissamu yona brenden terell treven tyrese adonys)

    # pick_name -- construct a unique user name based on sequence & world
    def pick_name(n,w)
      return USERNAMES[ (n % USERNAMES.size) ] + n.to_s + "_w#{w.to_s}"
    end
    
  end  # anon class extensions
# #############################################################################
# #############################################################################


  factory :tenant do |f|
    f.tenant_id   nil
  end
  
  factory :user do |f|
    w = binding.current_tenant    # establish a current tenant for this duration
    f.tenant_id   nil
    f.sequence( :email ) { |n| "#{binding.pick_name(n,w)}@example.com" }
    f.password  'MonkeyMocha'
    f.password_confirmation { |u| u.password }
  end  # user
  
  factory :author do |f|
    w = binding.current_tenant
    f.tenant_id  w
    f.sequence( :name ) { |n| "#{binding.pick_name(n,w)}@example.com" }
    f.association :user
  end   # :author
  
  factory :calendar do |f|
    f.tenant_id  binding.current_tenant
    f.association :team
    f.cal_start   Time.now.at_beginning_of_month 
    f.cal_end     Time.now.at_end_of_month
  end   # calendar
  
  factory :team do |f|
    f.tenant_id  binding.current_tenant
    f.sequence( :name ) { |n| "team_#{n}" }
    f.after_create {|team| f.team_assets = 3.times{ Factory(:team_asset, :team => team) } }
  end  # team
  
  factory :team_asset do |f|
    f.tenant_id   binding.current_tenant
    f.association :team
    f.association :author
  end
  
  factory :zine do |f|
    f.tenant_id   binding.current_tenant
    f.association :calendar
  end
  
  CONTENT = %w(wild_blue passion_pink mellow_yellow)
  
  factory :post do |f|
    f.tenant_id   binding.current_tenant
    f.sequence( :content ) {|n| CONTENT[n % 3] + "_#{n}" }
    f.association :author
    f.association :zine
  end

end  # FactoryGirl.define
