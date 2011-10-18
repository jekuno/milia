FactoryGirl.define do
  
  class << self
    USERNAMES = %w(demarcus deshaun jemell jermaine jabari kwashaun musa nigel kissamu yona brenden terell treven tyrese adonys)

    def pick_name(n)
      return USERNAMES[ (n % USERNAMES.size) ] + n.to_s
    end
    
  end
  
  factory :tenant do |f|
    f.tenant_id   nil
  end
  
  factory :user do |f|
    f.tenant_id   nil
    f.sequence( :email ) { |n| "#{pick_name(n)}@example.com" }
    f.password  'MonkeyMocha'
    f.password_confirmation { |u| u.password }
  end  # user
  
  factory :author do |f|
    f.sequence( :name ) { |n| "#{pick_name(n)}@example.com" }
    f.association :user
  end   # :author
  
  factory :calendar do |f|
    
  end   # calendar
  
  
end
