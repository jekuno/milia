  class << self
    USERNAMES = %w(demarcus deshaun jemell jermaine jabari kwashaun musa nigel kissamu yona brenden terell treven tyrese adonys)

#    def pick_name(n)
#      return USERNAMES[ (n % USERNAMES.size) ] + n.to_s
#    end
    
    def current_tenant()
      return Thread.current[:tenant_id]
    end
    
    
  end  # anon class extensions

FactoryGirl.define do
  
  
  factory :tenant do |f|
    f.tenant_id   nil
  end
  
  factory :user do |f|
    f.tenant_id   nil
    f.sequence( :email ) { |n| "bob#{n}@example.com" }
    f.password  'MonkeyMocha'
    f.password_confirmation { |u| u.password }
  end  # user
  
  factory :author do |f|
    f.tenant_id  Thread.current[:tenant_id]
    f.sequence( :name ) { |n| "#{pick_name(n)}@example.com" }
    f.association :user
  end   # :author
  
  factory :calendar do |f|
    f.tenant_id  Thread.current[:tenant_id]
    f.association :team
    f.cal_start   Time.now.at_beginning_of_month 
    f.cal_end     Time.now.at_end_of_month
  end   # calendar
  
  factory :team do |f|
    f.tenant_id  Thread.current[:tenant_id]
    f.sequence( :name ) { |n| "team_#{n}" }
  end  # team
  
  factory :team_asset do |f|
    f.tenant_id   Thread.current[:tenant_id]
    f.association :team
    f.association :author
  end
  
  
end  # FactoryGirl.define
