class Campaign < ActiveRecord::Base
  extend FriendlyId
  friendly_id :name, use: :slugged
  
  attr_accessible :name, :goal,  :expiration_date, :ct_campaign_id, :media_type, 
                  :main_image, :main_image_delete, :video_embed_id, :video_placeholder, :video_placeholder_delete,
                  :contributor_reference, :progress_text, :primary_call_to_action_button, :primary_call_to_action_description,
                  :secondary_call_to_action_button, :secondary_call_to_action_description, :main_content, 
                  :checkout_sidebar_content, :confirmation_page_content, :confirmation_email_content,
                  :tweet_text, :facebook_title, :facebook_description,  :facebook_image, :facebook_image_delete,
                  :payment_type, :fixed_payment_amount, :min_payment_amount, :apply_processing_fee,
                  :collect_shipping_address               
                  
  attr_accessor :main_image_delete, :video_placeholder_delete, :facebook_image_delete
  
  validates :name, :goal, :expiration_date, presence: true
  validates :min_payment_amount, numericality: { greater_than_or_equal_to: 1.0 }
  validates :fixed_payment_amount, numericality: { greater_than_or_equal_to: 1.0 }
  validate :expiration_date_cannot_be_in_the_past
  
  before_validation { main_image.clear if main_image_delete == '1' }
  before_validation { video_placeholder.clear if video_placeholder_delete == '1' }
  before_validation { facebook_image.clear if facebook_image_delete == '1' }

  has_attached_file :main_image, 
                    styles: { main: "512x385!", thumb: "100x100#" }   
  
  has_attached_file :video_placeholder, 
                    styles: { main: "512x385!", thumb: "100x100#" }  #The hash indicates cropping, use ! for forced scaling                   
                    
  has_attached_file :facebook_image, 
                    styles: { thumb: "100x100#" }

  before_save :set_min_amount
  
  #This ensures that a new slug is not created if the name changes
  def should_generate_new_friendly_id?
    new_record?
  end
  
  private
  
  def set_min_amount  
    if self.payment_type == "any"
      self.min_payment_amount = 1.0
    end
  end

  def expiration_date_cannot_be_in_the_past
    if !expiration_date.blank? and expiration_date < Date.today
      errors.add(:expiration_date, "can't be in the past")
    end
  end
end
