class AdminController < ApplicationController
  layout "admin"
  before_filter :authenticate_user!
  before_filter :verify_admin
  
  def admin_website

    #Handle the form submission if request is PUT
    if request.put?
      if @settings.update_attributes(params[:settings])
        flash.now[:success] = "Website settings successfully updated!"
      else
        flash.now[:error] = "Error"
      end 
         
    end
  end  
  
  def admin_bank_setup
    @bank = {}
    
    if current_user.has_default_bank
      begin
        response = Crowdtilt.get('/users/' + current_user.ct_user_id + '/banks/default')
      rescue => exception
        flash.now[:error] = exception.to_s
      else
        @bank = response['bank']
      end    
    elsif request.post?
      if params[:ct_bank_id].blank?
        flash.now[:error] = "An error occurred, please try again"
      else
        begin
          bank = {
            id: params[:ct_bank_id]
          }
          response = Crowdtilt.post('/users/' + current_user.ct_user_id + '/banks/default', {bank: bank})
        rescue => exception
          flash.now[:error] = exception.to_s
        else
          @bank = response['bank']
          current_user.has_default_bank = true
          current_user.save
        end
      end
    end
    
  end
  
  def ajax_verify
    if params[:name].blank? || params[:phone].blank? || params[:street_address].blank? || params[:postal_code].blank? || params[:dob].blank?
      render text: "error" #not all fields filled out
    else
      response = Crowdtilt.get('/users/' + current_user.ct_user_id)
      if response['user']['is_verified'] != 1     
        begin
          verification = {
            name: params[:name],
            phone_number: params[:phone],
            street_address: params[:street_address],
            postal_code: params[:postal_code],
            dob: params[:dob]
          }                      
          response = Crowdtilt.post('/users/' + current_user.ct_user_id + '/verification', {verification: verification})                     
        rescue => exception
          render text: exception.to_s #failed to verify through Crowdtilt API
        else
          render text: "success" #successfully verified through Crowdtilt API
        end
      else
        render text: "success"  #already verified
      end
    end
  end

end