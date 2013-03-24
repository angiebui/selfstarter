class ApplicationController < ActionController::Base
  protect_from_forgery

  before_filter :load_settings
  after_filter :store_location
  
  def load_settings
    @settings = Settings.find_by_id(1)   
    
    if !@settings
      redirect_to :status => 404
    end   
  end
  
  def store_location
    # store last url as long as it isn't an /account path
    session[:previous_url] = request.fullpath unless request.fullpath =~ /\/account/
  end
  
  def after_sign_in_path_for(resource)
    session[:previous_url] || root_path
  end

  def verify_admin
    if !current_user.admin?
      redirect_to root_url, :flash => { :notice => "You must be an admin to access that page" }
   end
  end  
end
