class Settings < ActiveRecord::Base
attr_accessible :project_name, :tagline, :project_goal,  :expiration_date, :contributor_reference,
                :primary_call_to_action_button, :primary_call_to_action_description, :secondary_call_to_action_button,
                :secondary_call_to_action_description, :main_content, :amazon_access_key, :amazon_secret_key, :charge_limit, 
                :facebook_app_id, :google_id, :price, :progress_text, :tweet_text, :use_payment_options, 
                :use_video_placeholder, :video_embed_url, :initialized_flag, :video_placeholder, :video_placeholder_delete
                
attr_accessor :video_placeholder_delete

before_validation { video_placeholder.clear if video_placeholder_delete == '1' }

has_attached_file :video_placeholder , styles: { main: "512x385!", thumb: "100x100#" }  #The hash indicates cropping, use ! for forced scaling

end
