class Settings < ActiveRecord::Base
  attr_accessible :project_name, :tagline, :project_goal,  :expiration_date, :contributor_reference,
                  :primary_call_to_action_button, :primary_call_to_action_description, :secondary_call_to_action_button,
                  :secondary_call_to_action_description, :main_content, :facebook_app_id, :google_id, :tweet_text, 
                  :use_payment_options, :video_embed_url, :initialized_flag, :video_placeholder, :video_placeholder_delete,
                  :ct_campaign_id, :media_type, :payment_type, :fix_payment_amount, :min_payment_amount, :user_fee_amount, 
                  :logo_image, :project_image, :logo_image_delete, :project_image_delete, :checkout_content,
                  :copyright_text, :facebook_title, :facebook_description, :confirmation_page_content, 
                  :confirmation_email_content, :facebook_image, :facebook_image_delete
                  
  attr_accessor :video_placeholder_delete, :logo_image_delete, :project_image_delete, :facebook_image_delete
  
  validates :project_name, :project_goal, :expiration_date, :contributor_reference, presence: true
  validates :min_payment_amount, numericality: { greater_than_or_equal_to: 1.0 }
  validates :fix_payment_amount, numericality: { greater_than_or_equal_to: 1.0 }
  validates :user_fee_amount, numericality: { greater_than_or_equal_to: 0 }
  
  before_validation { video_placeholder.clear if video_placeholder_delete == '1' }
  before_validation { logo_image.clear if logo_image_delete == '1' }
  before_validation { project_image.clear if project_image_delete == '1' }
  before_validation { facebook_image.clear if project_image_delete == '1' }
  
  has_attached_file :video_placeholder, 
                    styles: { main: "512x385!", thumb: "100x100#" }  #The hash indicates cropping, use ! for forced scaling

  
  has_attached_file :logo_image, 
                    styles: { thumb: "100x100#" }
                    
  has_attached_file :project_image, 
                    styles: { main: "512x385!", thumb: "100x100#" }                   
                    
                    
  has_attached_file :facebook_image, 
                    styles: { thumb: "100x100#" }

  before_save :set_min_amount
  
  private
  
  def set_min_amount  
    if self.payment_type == "any"
      self.min_payment_amount = 1.0
    end
  end
    
end
