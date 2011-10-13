class Post < ActiveRecord::Base
  acts_as_tenant
  
  belongs_to  :author
  belongs_to  :zine
end
