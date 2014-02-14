FactoryGirl.define do |binding|
 

  sequence :tenant_name do |n|
    "tenant_#{n}"
  end

  factory :tenant do
    name   generate :tenant_name
  end

  sequence :user_email do |n|
    # sequence( :email ) { |n| "#{binding.pick_name(n,w)}@example.com" }
    "emailuser_#{n}"
  end

  factory :user do
    email      generate :user_email
    password  'MonkeyMocha'
    password_confirmation { |u| u.password }
  end  # user
 
end  # factorygirl define
