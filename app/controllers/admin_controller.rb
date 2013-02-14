class AdminController < ApplicationController
  layout "admin"
  before_filter :authenticate_user!
  before_filter :verify_admin

  
  def verify_admin
    if !current_user.admin?
      redirect_to root_url, :flash => { :notice => "You must be an admin to access that page" }
    end
  end
  
  def admin_project
      if request.put?
      @settings.update_attributes(params[:settings])
       
      redirect_to admin_project_path, :flash => { :success => "Project Updated!" }
    end
  end

end