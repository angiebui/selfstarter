class ApplicationController < ActionController::Base
  protect_from_forgery

  before_filter :load_settings, :initialize_crowdtilt_api
  after_filter :store_location
  
  def load_settings
    @settings = Settings.find_by_id(1)   
    
    if !@settings
      redirect_to :status => 404
    end   
  end
  
  def initialize_crowdtilt_api
    Crowdtilt.configure {key Rails.configuration.crowdtilt_key; secret Rails.configuration.crowdtilt_secret; env Rails.env}
  end
  
  def store_location
    # store last url as long as it isn't an /account path
    session[:previous_url] = request.fullpath unless request.fullpath =~ /\/account/
  end
  
  def after_sign_in_path_for(resource)
    session[:previous_url] || root_path
  end
  
end
