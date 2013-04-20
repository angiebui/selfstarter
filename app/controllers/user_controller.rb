class UserController < ApplicationController
  before_filter :authenticate_user!

  def payments
    begin
      response = Crowdtilt.get('/users/' + current_user.ct_user_id + '/payments')
    rescue => e
      flash.now[:error] = e.to_s
      @payments = []
    else
      @payments = response['payments']
    end
  end
  
end
