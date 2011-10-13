class Post < ActiveRecord::Base
  acts_as_tenant
  belongs_to :user
end
