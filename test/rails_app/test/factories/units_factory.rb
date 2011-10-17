FactoryGirl.define do
  USERNAMES = %w(demarcus deshaun jemell jermaine jabari kwashaun musa nigel kissamu yona brendon terell treven tyrese adonys)
  
  factory :user do
    f.sequence( :email ) do |n|
      ndex = n % USERNAMES.size
      "#{USERNAMES[ndex]}#{n}@example.com"
    end
    
  end
  
end
