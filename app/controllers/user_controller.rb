class UserController < ApplicationController
  before_filter :authenticate_user!

  def payments
    @payments = Crowdtilt::User.find(current_user.ct_user_id).payments
  end
  
end
