class Reward < ActiveRecord::Base
  attr_accessible :title, :description, :delivery_date, :number, :price, :campaign_id
 	
 	validates :title, :description, :delivery_date, :price, presence: true
 								
  belongs_to :campaign
  has_many :payments
  
  def sold_out?
  	!self.unlimited? && self.payments.length >= self.number
  end
  
  def unlimited?
  	self.number.nil? || self.number == 0
  end

end
