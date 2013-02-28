class AdminController < ApplicationController
  layout "admin"
  before_filter :authenticate_user!
  before_filter :verify_admin
  
  def admin_project
    @faqs = Faq.all
    if request.put?
      @settings.update_attributes(params[:settings])
      
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
                                           description: @settings.tagline, 
                                           tilt_amount: @settings.project_goal*100, 
                                           expiration_date: @settings.expiration_date, 
                                           user_id: current_user.ct_user_id
        begin
          campaign.save
        rescue => exception     
          flash.now[:error] = exception.to_s
        else
          @settings.update_attribute :ct_campaign_id, campaign.id
          flash.now[:success] = "Project updated!"
        end          
      
      else   
        campaign = Crowdtilt::Campaign.find(@settings.ct_campaign_id)
       
        campaign.title = @settings.project_name
        campaign.description = @settings.tagline
        campaign.tilt_amount = @settings.project_goal*100
        campaign.expiration_date = @settings.expiration_date

        begin
          campaign.save
        rescue => exception     
          flash.now[:error] = exception.to_s
        else
          flash.now[:success] = "Project updated!"
        end    
      end    
    end
  end
  
  def admin_contributors
    if !@settings.ct_campaign_id
      redirect_to admin_project_path, :flash => { :error => "Project is not set up yet!" }
    else
      @contributors = Crowdtilt::Campaign.find(@settings.ct_campaign_id).payments
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