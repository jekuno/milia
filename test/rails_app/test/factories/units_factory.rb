FactoryGirl.define do |binding|
  
# #############################################################################
# ************* HELPER METHODS FOR THIS FACTORY *******************************
# #############################################################################
  class << binding
    
    def current_tenant()
      @current_tenant ||= Factory(:tenant)
      Thread.current[:tenant_id] = @current_tenant.id
    end

    USERNAMES = %w(demarcus deshaun jemell jermaine jabari kwashaun musa nigel kissamu yona brenden terell treven tyrese adonys)

    def pick_name(n)
      return USERNAMES[ (n % USERNAMES.size) ] + n.to_s
    end

  end  # anon class extensions
# #############################################################################
# #############################################################################


  factory :tenant do |f|
    f.tenant_id   nil
  end
  
  factory :user do |f|
    f.tenant_id   nil
    f.sequence( :email ) { |n| "#{binding.pick_name(n)}@example.com" }
    f.password  'MonkeyMocha'
    f.password_confirmation { |u| u.password }
    binding.current_tenant    # establish a current tenant for this duration
  end  # user
  
  factory :author do |f|
    f.tenant_id  binding.current_tenant
    f.sequence( :name ) { |n| "#{binding.pick_name(n)}@example.com" }
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
  
  
  factory :post do |f|
    f.tenant_id   binding.current_tenant
    f.association :author
    f.association :zine
  end

end  # FactoryGirl.define
