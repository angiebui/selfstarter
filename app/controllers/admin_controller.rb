class AdminController < ApplicationController
  layout "admin"
  before_filter :authenticate_user!
  before_filter :verify_admin
  
  def admin_project
    if request.put?
      @settings.update_attributes(params[:settings])
      
      #Whenever the project details are saved, we'll update (or create) a corresponding 
      #campaign through the Crowdtilt API     
      if !@settings.ct_campaign_id
      
        campaign = Crowdtilt::Campaign.new title: @settings.project_name, description: @settings.tagline, 
                                           tilt_amount: @settings.project_goal*100, expiration_date: @settings.expiration_date, 
                                           user_id: current_user.ct_user_id
        begin
          campaign.save
        rescue => exception     
          redirect_to admin_project_path, :flash => { :error => exception.to_s }
        else
          @settings.update_attribute :ct_campaign_id, campaign.id
          redirect_to admin_project_path, :flash => { :success => "Project updated!" }
        end          
      
      else
        redirect_to admin_project_path, :flash => { :success => "Project updated!" }

#TODO: campaign updates through the API is broken at the moment      
#         campaign = Crowdtilt::Campaign.find(@settings.ct_campaign_id)
#        
#         campaign.title = @settings.project_name
#         campaign.description = @settings.tagline
#         campaign.tilt_amount = @settings.project_goal*100
#         campaign.expiration_date = @settings.expiration_date
# 
#         begin
#           campaign.save
#         rescue => exception     
#           redirect_to admin_project_path, :flash => { :error => exception.to_s }
#         else
#           redirect_to admin_project_path, :flash => { :success => "Project updated!" }
#         end          
      end    
      
    end
  end
  
  def admin_contributors
    @contributors = Crowdtilt::Campaign.find(@settings.ct_campaign_id).payments
  end
  
  
  protected
  
    def verify_admin
      if !current_user.admin?
        redirect_to root_url, :flash => { :notice => "You must be an admin to access that page" }
     end
    end

end