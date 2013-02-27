class Settings < ActiveRecord::Base
attr_accessible :project_name, :tagline, :project_goal,  :expiration_date, :contributor_reference,
                :primary_call_to_action_button, :primary_call_to_action_description, :secondary_call_to_action_button,
                :secondary_call_to_action_description, :main_content, :amazon_access_key, :amazon_secret_key, :charge_limit, 
                :facebook_app_id, :google_id, :price, :progress_text, :tweet_text, :use_payment_options, 
                :use_video_placeholder, :video_embed_url, :initialized_flag, :video_placeholder, :video_placeholder_delete,
                :ct_campaign_id, :media_type, :payment_type, :fix_payment_amount, :min_payment_amount, :user_fee_amount, 
                :logo_image, :project_image, :logo_image_delete, :project_image_delete, :checkout_content
                
attr_accessor :video_placeholder_delete, :logo_image_delete, :project_image_delete

before_validation { video_placeholder.clear if video_placeholder_delete == '1' }
before_validation { logo_image.clear if logo_image_delete == '1' }
before_validation { project_image.clear if project_image_delete == '1' }

has_attached_file :video_placeholder, styles: { main: "512x385!", thumb: "100x100#" }  #The hash indicates cropping, use ! for forced scaling

has_attached_file :logo_image, styles: { thumb: "100x100#" }
has_attached_file :project_image, styles: { main: "512x385!", thumb: "100x100#" }
end
