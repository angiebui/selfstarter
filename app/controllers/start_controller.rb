class StartController < ApplicationController
  before_filter :check_init
  before_filter :authenticate_user!, :only => :start_init

  def check_init
    if @settings.initialized_flag
      redirect_to root_url, :flash => { :notice => "App is already initialized!" }
    end
  end

  def start
  end

  def start_init
    
    # Create the Admin User
    current_user.update_attribute :admin, true  
    
    # Set intiatilized flag to true
    @settings.initialized_flag = true;
    @settings.save
    
    # Put user back on admin area
    redirect_to admin_project_path
  end

end
