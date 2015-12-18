module Milia
  class UnlocksController < Devise::UnlocksController
    # skip need for authentication
    skip_before_action :authenticate_tenant!
  end
end
