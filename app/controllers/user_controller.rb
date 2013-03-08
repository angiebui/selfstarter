class UserController < ApplicationController
  before_filter :authenticate_user!

  def payments
    begin
    @payments = Crowdtilt::User.find(current_user.ct_user_id).payments
    rescue => e
      flash.now[:error] = e.to_s
      @payments = []
    end
  end
  
end
