class Payment < ActiveRecord::Base
  attr_accessible :ct_payment_id, :status, :amount, :user_fee_amount, :admin_fee_amount, :fullname, :email,
  								:card_type, :card_last_four, :card_expiration_month, :card_expiration_year,
  								:address_one, :address_two, :city, :state, :postal_code, :country, :quantity
 	
 	validates :fullname, :email, :quantity, presence: true
 	validate :check_email
 								
  belongs_to :campaign
  
  def update_api_data(payment)
    self.ct_payment_id = payment['id']
    self.status = payment['status']
    self.amount = payment['amount']
    self.user_fee_amount = payment['user_fee_amount']
    self.admin_fee_amount = payment['admin_fee_amount']
    self.card_type = payment['card']['card_type']
    self.card_last_four = payment['card']['last_four']
    self.card_expiration_month = payment['card']['expiration_month']
    self.card_expiration_year = payment['card']['expiration_year']
  end
  
  private
  
  def check_email
  	if !self.email.nil?
		  unless self.email =~ /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i
		    errors.add(:email, self.email + "is not a valid email address")
		  end
		end
  end
end