class Settings < ActiveRecord::Base
  attr_accessible :site_name, :facebook_app_id, :google_id, :tweet_text, :initialized_flag, 
                  :logo_image, :logo_image_delete, :copyright_text, :facebook_title, 
                  :facebook_description, :facebook_image, :facebook_image_delete, :homepage_content,
                  :custom_css
                  
  attr_accessor :logo_image_delete, :facebook_image_delete
  
  validates :site_name, presence: true

  before_validation { logo_image.clear if logo_image_delete == '1' }
  before_validation { facebook_image.clear if facebook_image_delete == '1' }
  
  has_attached_file :logo_image, 
                    styles: { thumb: "100x100#" }
                         
  has_attached_file :facebook_image, 
                    styles: { thumb: "100x100#" }
    
end
