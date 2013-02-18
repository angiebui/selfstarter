class ProjectController < ApplicationController
  skip_before_filter :verify_authenticity_token, :only => :ipn
  before_filter :check_init
  before_filter :check_project, only: [:checkout, :checkout_payment]
  
  def homepage
    @campaign = Crowdtilt::Campaign.find(@settings.ct_campaign_id)
  end

  def checkout
  end
  
  def checkout_payment
    if !current_user
      redirect_to new_user_registration_path
    end
  end
  
  def ajax_checkout
    card_id = params[:card][:id]     
    amount = params[:amount].to_f * 100
    
    # TODO: should be a setting to determine whether or not this is applied
    user_fee_amount = amount * 0.025
    
    payment = Crowdtilt::Payment.new amount: amount, user_fee_amount: user_fee_amount, admin_fee_amount: 0, 
                                     user_id: current_user.ct_user_id, card_id: card_id, 
                                     campaign_id: @settings.ct_campaign_id
    payment.save  
    
    render text: "payment: " + payment.id
  end
  
  def confirmation
  end
  
  def prefill
    @user  = User.find_or_create_by_email!(params[:email])

    if @settings.use_payment_options
      payment_option_id = params['payment_option']
      raise Exception.new("No payment option was selected") if payment_option_id.nil?
      payment_option = PaymentOption.find(payment_option_id)
      price = payment_option.amount
    else
      price = @settings.price
    end

    @order = Order.prefill!(:name => @settings.product_name, :price => price, :user_id => @user.id, :payment_option => payment_option)

    # This is where all the magic happens. We create a multi-use token with Amazon, letting us charge the user's Amazon account
    # Then, if they confirm the payment, Amazon POSTs us their shipping details and phone number
    # From there, we save it, and voila, we got ourselves a preorder!
    @pipeline = AmazonFlexPay.multi_use_pipeline(@order.uuid,
                                                 :transaction_amount => price,
                                                 :global_amount_limit => price + @settings.charge_limit,
                                                 :collect_shipping_address => "True",
                                                 :payment_reason => @settings.payment_description)


    port = Rails.env.production? ? "" : ":3000"
    redirect_to @pipeline.url("#{request.scheme}://#{request.host}#{port}/preorder/postfill")
  end

  def postfill
    unless params[:callerReference].blank?
      @order = Order.postfill!(params)
    end
    # "A" means the user cancelled the preorder before clicking "Confirm" on Amazon Payments.
    if params['status'] != 'A' && @order.present?
      redirect_to :action => :share, :uuid => @order.uuid
    else
      redirect_to root_url
    end
  end

  def share
    @order = Order.find_by_uuid(params[:uuid])
  end

  def ipn
  end
  
  protected
  
    #Function to initialize a new app
    #The first user to sign in automatically becomes the admin user
    def check_init
      if !@settings.initialized_flag
        if current_user
          # Create the Admin User
          current_user.update_attribute :admin, true  
          
          # Set intiatilized flag to true
          @settings.update_attribute :initialized_flag, true
          
          # Put user back on admin area
          redirect_to admin_project_path, :flash => { :success => "Nice! Your app is now initialized." }        
        else
          redirect_to new_user_registration_path, :flash => { :error => "App is not initialized" }
        end 
      end
    end
    
    def check_project
      if !@settings.ct_campaign_id
        redirect_to root_path, :flash => { :error => "Project is not set up yet!" }
      end
    end
  
  
end
