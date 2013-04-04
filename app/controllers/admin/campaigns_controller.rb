class Admin::CampaignsController < ApplicationController
  layout "admin"
  before_filter :authenticate_user!
  before_filter :verify_admin
  
  def index
    @campaigns = Campaign.all
  end
  
  def new
    @campaign = Campaign.new
  end

  def create
    @campaign = Campaign.new(params[:campaign])
    
    # Check if the new settings pass validations...if not, re-render form and display errors in flash msg
    if !@campaign.valid?   
      message = ''
      @campaign.errors.each do |key, error|
        message = message + key.to_s.humanize + ' ' + error.to_s + ', '
      end
      flash.now[:error] = message[0...-2]
      render action: "new"
      return
    end
            
    # Update the corresponding campaign on the Crowdtilt API
    # If it fails, echo the error message sent by the API back to the user
    # If successful, save the campaign         
    ct_campaign = Crowdtilt::Campaign.new title: @campaign.name, 
                                          tilt_amount: @campaign.goal*100, 
                                          expiration_date: @campaign.expiration_date, 
                                          user_id: current_user.ct_user_id
    begin
      ct_campaign.save
    rescue => exception  
      flash.now[:error] = exception.to_s
      render action: "new"
      return
    else
      @campaign.update_api_data(ct_campaign)
      @campaign.save 
      
      # Now that we've created the campaign, create new FAQs if any were provided
      if params.has_key?(:faq)        
        params[:faq].each do |faq|
          if !faq['question'].empty?
            @campaign.faqs.create question: faq['question'], answer: faq['answer']
          end 
        end
      end      
      
      if @campaign.archive_flag              
        redirect_to admin_campaigns_url, :flash => { :notice => "Campaign created!" }
      else  
        redirect_to campaign_home_url(@campaign), :flash => { :notice => "Campaign created!" }
      end
      return
    end 
  end
  
  def edit
    @campaign = Campaign.find(params[:id])
  end
  
  def update
    @campaign = Campaign.find(params[:id])
     
    # Completely refresh the FAQ data
    @campaign.faqs.delete_all 
    if params.has_key?(:faq)        
      params[:faq].each do |faq|
        if !faq['question'].empty?
          @campaign.faqs.create question: faq['question'], answer: faq['answer']
        end 
      end
    end   
    
    # We don't immediately update the campaign, becuase the Crowdtilt API may still fail a validation
    @campaign.assign_attributes(params[:campaign])
    
    # Check if the new settings pass validations...if not, re-render form and display errors in flash msg
    if !@campaign.valid?   
      message = ''
      @campaign.errors.each do |key, error|
        message = message + key.to_s.humanize + ' ' + error.to_s + ', '
      end
      flash.now[:error] = message[0...-2]
      render action: "edit"
      return
    end
          
    # Update the corresponding campaign on the Crowdtilt API
    # If it fails, echo the error message sent by the API back to the user
    # If successful, save the campaign         
    ct_campaign = Crowdtilt::Campaign.find(@campaign.ct_campaign_id) 
    ct_campaign.title = @campaign.name
    ct_campaign.tilt_amount = @campaign.goal*100
    ct_campaign.expiration_date = @campaign.expiration_date
    
    begin
      ct_campaign.save
    rescue => exception   
      flash.now[:error] = exception.to_s
      render action: "edit"
      return
    else
      @campaign.update_api_data(Crowdtilt::Campaign.find(@campaign.ct_campaign_id))
      @campaign.save
      if @campaign.archive_flag              
        redirect_to admin_campaigns_url, :flash => { :notice => "Campaign updated!" }
      else  
        redirect_to campaign_home_url(@campaign), :flash => { :notice => "Campaign updated!" }
      end
      return
    end     
  end

  def contributors
    @campaign = Campaign.find(params[:id])
    page = params[:page] || 1

    #Check if the user is searching for a certain payment_id
    if params.has_key?(:payment_id) && !params[:payment_id].blank?
      begin
        @contributors = [Crowdtilt::Campaign.find(@campaign.ct_campaign_id).payments.find(params[:payment_id])]
        @page = @total_pages = 1
      rescue => exception
        #This means the payment_id wasn't found, so go ahead and grab all payments
        @contributors = Crowdtilt::Campaign.find(@campaign.ct_campaign_id).payments(page, 50)
        @page = @contributors.pagination['page'].to_i
        @total_pages = @contributors.pagination['total_pages'].to_i
        flash.now[:error] = "Contributor not found for " + params[:payment_id]
      end
    else
      @contributors = Crowdtilt::Campaign.find(@campaign.ct_campaign_id).payments(page, 50)
      @page = @contributors.pagination['page'].to_i
      @total_pages = @contributors.pagination['total_pages'].to_i
    end
  end

end
