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
  
  def contributors
    
    page = params[:page] || 1
  
    if !@settings.ct_campaign_id
      redirect_to admin_project_url, :flash => { :notice => "Please submit the project form below to confirm your settings." }
    else
      #Check if the user is searching for a certain payment_id
      if params.has_key?(:payment_id) && !params[:payment_id].blank?
        begin
          @contributors = [Crowdtilt::Campaign.find(@settings.ct_campaign_id).payments.find(params[:payment_id])]
          @page = @total_pages = 1
        rescue => exception
          #This means the payment_id wasn't found, so go ahead and grab all payments
          @contributors = Crowdtilt::Campaign.find(@settings.ct_campaign_id).payments(page, 50)
          @page = @contributors.pagination['page'].to_i
          @total_pages = @contributors.pagination['total_pages'].to_i
          flash.now[:error] = "Contributor not found for " + params[:payment_id]
        end
      else
        @contributors = Crowdtilt::Campaign.find(@settings.ct_campaign_id).payments(page, 50)
        @page = @contributors.pagination['page'].to_i
        @total_pages = @contributors.pagination['total_pages'].to_i
      end
    end
  end
  
  def admin_bank_setup
    user = Crowdtilt::User.find(current_user.ct_user_id)
    
    if current_user.has_default_bank
      @bank = user.get_default_bank 
    elsif request.post?
      if params[:ct_bank_id].blank?
        flash.now[:error] = "An error occurred, please try again"
      else
        begin
          @bank = user.get_bank(params[:ct_bank_id])
          @bank.set_as_default
        rescue => exception
          flash.now[:error] = exception.to_s
        else
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
      user = Crowdtilt::User.find(current_user.ct_user_id)
      
      if !user.verified?      
        begin
          user.verify name: params[:name], phone_number: params[:phone], 
                      street_address: params[:street_address], postal_code: params[:postal_code], 
                      dob: params[:dob]
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