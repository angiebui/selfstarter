class CampaignsController < ApplicationController
  before_filter :check_init
  before_filter :load_campaign
  before_filter :check_archive
  before_filter :check_exp, :except => [:home, :checkout_confirmation]

  def home
    render 'theme/views/campaign'
  end
  
  def checkout_amount
    if @campaign.payment_type == "fixed"
      redirect_to checkout_payment_url(@campaign)
      return
    end
  end
  
  def checkout_payment
    if @campaign.payment_type == "fixed"
      @amount = ((@campaign.fixed_payment_amount.to_f)*100).ceil/100.0
    elsif params.has_key?(:amount) && params[:amount].to_f >= @campaign.min_payment_amount
      @amount = ((params[:amount].to_f)*100).ceil/100.0 
    else
      redirect_to checkout_amount_url(@campaign), flash: { error: "Invalid amount!" }
      return
    end
    
    @fee = (@campaign.apply_processing_fee)? ((@amount * Rails.configuration.processing_fee.to_f/100)*100).ceil/100.0 : 0
    @total = ((@amount + @fee)*100).ceil/100.0
    
  end
  
  def checkout_confirmation  
    if params[:ct_user_id].blank? || params[:ct_card_id].blank? || params[:amount].blank? || params[:fee].blank?
      redirect_to checkout_amount_url, flash: { error: "An error occurred" }
      return
    end
    
    ct_user_id = params[:ct_user_id]
    ct_card_id = params[:ct_card_id]
    amount = params[:amount].to_f * 100
    
    if @campaign.apply_processing_fee
      user_fee_amount = params[:fee].to_f * 100
      admin_fee_amount = 0
    else
      user_fee_amount = 0
      admin_fee_amount = params[:fee].to_f * 100
    end
       
    if !ct_user_id == current_user.ct_user_id
      redirect_to checkout_payment_url(:amount => params[:amount]), flash: { error: "Invalid user!" }
    end
    
    #TODO: Check to make sure the amount is valid here
    
    @payment = Crowdtilt::Payment.new amount: amount, user_fee_amount: user_fee_amount, 
                                      admin_fee_amount: admin_fee_amount, user_id: ct_user_id, 
                                      card_id: ct_card_id, campaign_id: @campaign.ct_campaign_id
    begin
     @payment.save
    rescue => exception
      flash.now[:error] = exception.to_s
      return
    end    
     
    begin
      UserMailer.payment_confirmation(@payment).deliver
    rescue => exception
    end
    
    @campaign.update_api_data(@payment.campaign)
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
