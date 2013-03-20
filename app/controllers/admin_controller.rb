class AdminController < ApplicationController
  layout "admin"
  before_filter :authenticate_user!
  before_filter :verify_admin
  
  def admin_project
    
    #Load the faqs
    @faqs = Faq.all
    
    #Handle the form submission if request is PUT
    if request.put?
      
      #First assign the new settings values from the form entries
      @settings.assign_attributes(params[:settings])   # THIS MUST BE ASSIGN - TODO TODO
      
      #Check if the new settings pass validations...if not, re-render form and display errors in flash msg
      if !@settings.valid?   
        message = ''
        @settings.errors.each do |key, error|
          message = message + key.to_s.humanize + ' ' + error.to_s + ', '
        end
        @settings = Settings.find_by_id(1)
        flash.now[:error] = message[0...-2]
        return
      end
      
      #Completely refresh the FAQ data 
      Faq.delete_all
      if params.has_key?(:faq)        
        params[:faq].each do |faq|
          if !faq['question'].empty?
            Faq.create question: faq['question'], answer: faq['answer']
          end 
        end
      end
      @faqs = Faq.all
            
      #Whenever the project details are saved, we'll update (or create) a corresponding 
      #campaign through the Crowdtilt API     
      if !@settings.ct_campaign_id
      
        campaign = Crowdtilt::Campaign.new title: @settings.project_name, 
                                           tilt_amount: @settings.project_goal*100, 
                                           expiration_date: @settings.expiration_date, 
                                           user_id: current_user.ct_user_id
        begin
          campaign.save
        rescue => exception  
          @settings = Settings.find_by_id(1)
          flash.now[:error] = exception.to_s
          return
        else
          @settings.ct_campaign_id = campaign.id
          @settings.save
          flash.now[:success] = "Project updated!"               
        end          
      
      else   
        campaign = Crowdtilt::Campaign.find(@settings.ct_campaign_id)       
        campaign.title = @settings.project_name
        campaign.tilt_amount = @settings.project_goal*100
        campaign.expiration_date = @settings.expiration_date

        begin
          campaign.save
        rescue => exception   
          @settings = Settings.find_by_id(1)
          flash.now[:error] = exception.to_s
          return
        else
          @settings.save
          flash.now[:success] = "Project updated!"
        end    
      end    
    end
  end
  
  def admin_contributors
    
    page = params[:page] || 1
  
    if !@settings.ct_campaign_id
      redirect_to admin_project_path, :flash => { :notice => "Please submit the project form below to confirm your settings." }
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
  
  
  protected
  
    def verify_admin
      if !current_user.admin?
        redirect_to root_url, :flash => { :notice => "You must be an admin to access that page" }
     end
    end

end