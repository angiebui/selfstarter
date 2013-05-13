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
  
  def copy
    old_campaign = Campaign.find(params[:id])
    @campaign = old_campaign.dup
    @campaign.published_flag = false
    @campaign.production_flag = false 
    
    begin
      campaign = {
        title: @campaign.name, 
        tilt_amount: @campaign.goal_dollars*100, 
        expiration_date: @campaign.expiration_date, 
        user_id: @settings.ct_sandbox_admin_id,
        metadata: {
        	fullname: current_user.fullname,
        	email: current_user.email
        }
      }
      Crowdtilt.sandbox
      response = Crowdtilt.post('/campaigns', {campaign: campaign})
    rescue => exception
      redirect_to admin_campaigns, :flash => { :error => "An error occurred" }
    else
      @campaign.update_api_data(response['campaign'])
      @campaign.save
    end
    
    # Completely refresh the FAQ data
    old_campaign.faqs.each do |faq|
      @campaign.faqs.create question: faq['question'], answer: faq['answer']
    end 
    
    render action: "edit"
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
    
   	# Set the campaign user id
   	ct_user_id = @campaign.production_flag ? @settings.ct_production_admin_id : @settings.ct_sandbox_admin_id
    	
    # calculate the goal amount (in case of a tilt by orders campaign)
    @campaign.set_goal
            
    # Create a corresponding campaign on the Crowdtilt API
    # If it fails, echo the error message sent by the API back to the user
    # If successful, save the campaign         
    begin
      campaign = {
        title: @campaign.name, 
        tilt_amount: (@campaign.goal_dollars*100).to_i, 
        expiration_date: @campaign.expiration_date, 
        user_id: ct_user_id     
      }
      @campaign.production_flag ? Crowdtilt.production : Crowdtilt.sandbox
      response = Crowdtilt.post('/campaigns', {campaign: campaign})
    rescue => exception  
      flash.now[:error] = exception.to_s
      render action: "new"
      return
    else
      @campaign.update_api_data(response['campaign'])
      @campaign.save 
      
      # Now that we've created the campaign, create new FAQs if any were provided
      if params.has_key?(:faq)        
        params[:faq].each do |faq|
          if !faq['question'].empty?
            @campaign.faqs.create question: faq['question'], answer: faq['answer']
          end 
        end
      end      
      
      redirect_to campaign_home_url(@campaign), :flash => { :notice => "Campaign updated!" }
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
    
		# Set the campaign user id
   	ct_user_id = @campaign.production_flag ? @settings.ct_production_admin_id : @settings.ct_sandbox_admin_id

    #if campaign has been promoted to production, delete all sandbox payments
    if @campaign.production_flag && @campaign.production_flag_changed?
    	@campaign.payments.delete_all
    end
    
		# calculate the goal amount (in case of a tilt by orders campaign)
    @campaign.set_goal
          
    # Update the corresponding campaign on the Crowdtilt API
    # If it fails, echo the error message sent by the API back to the user
    # If successful, save the campaign         
    begin
      campaign = {
        title: @campaign.name, 
        tilt_amount: (@campaign.goal_dollars*100).to_i, 
        expiration_date: @campaign.expiration_date 
      }
      # If the campaign has been promoted to production, create a new campaign on the Crowtilt API
      if @campaign.production_flag && @campaign.production_flag_changed?
      	campaign[:user_id] = ct_user_id
      	Crowdtilt.production
      	response = Crowdtilt.post('/campaigns', {campaign: campaign})
      else
      	@campaign.production_flag ? Crowdtilt.production : Crowdtilt.sandbox
      	response = Crowdtilt.put('/campaigns/' + @campaign.ct_campaign_id, {campaign: campaign})
      end
    rescue => exception   
      flash.now[:error] = exception.to_s
      render action: "edit"
      return
    else
      @campaign.update_api_data(response['campaign'])
      @campaign.save
			
			redirect_to campaign_home_url(@campaign), :flash => { :notice => "Campaign updated!" }
      return
    end     
  end

  def payments
#     @campaign = Campaign.find(params[:id])
#     page = params[:page] || 1
# 
#     #Check if the user is searching for a certain payment_id
#     if params.has_key?(:payment_id) && !params[:payment_id].blank?
#       begin
#         response = Crowdtilt.get('/campaigns/' + @campaign.ct_campaign_id + '/payments/' + params[:payment_id])
#       rescue => exception
#         #This means the payment_id wasn't found, so go ahead and grab all payments
#         response = Crowdtilt.get('/campaigns/' + @campaign.ct_campaign_id + '/payments?page=1&per_page=50')
#         @contributors = response['payments']
#         @page = response['pagination']['page'].to_i
#         @total_pages = response['pagination']['total_pages'].to_i
#         flash.now[:error] = "Contributor not found for " + params[:payment_id]
#       else
#         @contributors = [response['payment']]
#         @page = @total_pages = 1
#       end
#     else
#       response = Crowdtilt.get('/campaigns/' + @campaign.ct_campaign_id + "/payments?page=#{page}&per_page=50")
#       @contributors = @contributors = response['payments']
#       @page = response['pagination']['page'].to_i
#       @total_pages = response['pagination']['total_pages'].to_i
#     end
		
		@campaign = Campaign.find(params[:id])
		if params.has_key?(:payment_id) && !params[:payment_id].blank?
			payment = Payment.find_by_ct_payment_id(params[:payment_id].strip)
			if payment
				@payments = [payment]
			else
				@payments = @campaign.payments
				flash.now[:error] = "Contributor not found for " + params[:payment_id]
			end
		else
			@payments = @campaign.payments
		end
  end

end
