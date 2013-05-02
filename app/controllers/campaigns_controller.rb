class CampaignsController < ApplicationController
  before_filter :check_init
  before_filter :load_campaign
  before_filter :check_archive
  before_filter :check_exp, :except => [:home, :checkout_confirmation]

	# The load_campaign before filter grabs the campaign object from the db 
  # and makes it available to all routes

  def home
    render 'theme/views/campaign'
  end
  
  def checkout_amount
  end
  
  def checkout_payment
    if @campaign.payment_type == "fixed"
      if params.has_key?(:quantity)
      	@quantity = params[:quantity].to_i
      	@amount = ((@quantity * @campaign.fixed_payment_amount.to_f)*100).ceil/100.0
      else	
      	redirect_to checkout_amount_url(@campaign), flash: { error: "Invalid quantity!" }
      	return
      end
    elsif params.has_key?(:amount) && params[:amount].to_f >= @campaign.min_payment_amount
      @amount = ((params[:amount].to_f)*100).ceil/100.0 
    else
      redirect_to checkout_amount_url(@campaign), flash: { error: "Invalid amount!" }
      return
    end
    
    @fee = (@campaign.apply_processing_fee)? ((@amount * (Rails.configuration.processing_fee.to_f/100))*100).ceil/100.0 : 0
    @total = @amount + @fee
    
  end
  
  def checkout_confirmation
    
    ct_user_id = params[:ct_user_id]
    ct_card_id = params[:ct_card_id]
    fullname = params[:fullname]
    email = params[:email]
    
    #calculate amount and fee in cents
		amount = (params[:amount].to_f*100).ceil
    fee = (amount * (Rails.configuration.processing_fee.to_f/100)).ceil
    
    # Apply the processing fee to the user or the admin
    if @campaign.apply_processing_fee
      user_fee_amount = fee
      admin_fee_amount = 0
    else
      user_fee_amount = 0
      admin_fee_amount = fee
    end

		# Quick double check that the crowdtilt user id passed up matches our app-wide guest id
    if !ct_user_id == @settings.ct_guest_user_id
      redirect_to checkout_amount_url, flash: { error: "Invalid user!" }
    end
    
    # TODO: Check to make sure the amount is valid here
		
		# Create the payment record in our db, if there are errors, redirect the user
    @payment = @campaign.payments.new fullname: fullname, email: email
                              
    if !@payment.valid?   
      message = ''
      @payment.errors.each do |key, error|
        message = message + key.to_s.humanize + ' ' + error.to_s + ', '
      end
      redirect_to checkout_amount_url, flash: { error: message[0...-2] }
      return
    end

		# Execute the payment via the Crowdtilt API, if it fails, redirect user                
    begin
      payment = {
        amount: amount,
        user_fee_amount: user_fee_amount,
        admin_fee_amount: admin_fee_amount,
        user_id: ct_user_id,
        card_id: ct_card_id,
        metadata: {
        	fullname: fullname,
        	email: email
        }     
      }
      response = Crowdtilt.post('/campaigns/' + @campaign.ct_campaign_id + '/payments', {payment: payment})
    rescue => exception
      redirect_to checkout_amount_url, flash: { error: exception.to_s }
      return
    end  
    
    # Send a confirmation email 
    begin
      UserMailer.payment_confirmation(@payment).deliver
    rescue => exception
    end 
    
    # Sync payment data
		@payment.update_api_data(response['payment'])
		@payment.save                    
    
    # Sync campaign data
    @campaign.update_api_data(response['payment']['campaign'])
    @campaign.save
  end
  
  private
  
  def load_campaign
    @campaign = Campaign.find(params[:id])
  end

  def check_archive
    if @campaign.archive_flag
      redirect_to root_url, :flash => { :error => "Campaign is no longer available" }
    end
  end
  
  def check_exp
    if @campaign.expired?
      redirect_to campaign_home_url, :flash => { :error => "Campaign is expired!" }
    end
  end

end
