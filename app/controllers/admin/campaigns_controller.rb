class Admin::CampaignsController < ApplicationController
  layout "admin"
  before_filter :authenticate_user!
  before_filter :verify_admin
  
  def index
    @campaigns = Campaign.all
  end
  
  def new
    @campaign = Campaign.new
    @faqs = []
  end

  def create
    @campaign = Campaign.new(params[:campaign])
    @faqs = Faq.all
    
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
          
    # Completely refresh the FAQ data 
    Faq.delete_all
    if params.has_key?(:faq)        
      params[:faq].each do |faq|
        if !faq['question'].empty?
          Faq.create question: faq['question'], answer: faq['answer']
        end 
      end
    end
    @faqs = Faq.all
            
    # Update the corresponding campaign on the Crowdtilt API
    # If it fails, echo the error message sent by the API back to the user
    # If successful, save the campaign         
    campaign = Crowdtilt::Campaign.new title: @campaign.name, 
                                       tilt_amount: @campaign.goal*100, 
                                       expiration_date: @campaign.expiration_date, 
                                       user_id: current_user.ct_user_id
    begin
      campaign.save
    rescue => exception  
      flash.now[:error] = exception.to_s
      render action: "new"
      return
    else
      @campaign.ct_campaign_id = campaign.id
      @campaign.save               
      redirect_to campaign_home_path(@campaign), :flash => { :notice => "Campaign updated!" }
      return
    end 
  end
  
  def edit
    @campaign = Campaign.find(params[:id])
    @faqs = Faq.all
  end
  
  def update
    @campaign = Campaign.find(params[:id])
    
    # We don't immediately update the campaign, becuase the Crowdtilt API may still fail a validation
    @campaign.assign_attributes(params[:campaign])
    
    @faqs = Faq.all
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
      @campaign.save
      redirect_to campaign_home_path(@campaign), :flash => { :notice => "Campaign updated!" }
      return
    end     
  end

end
