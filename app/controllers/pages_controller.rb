class PagesController < ApplicationController
  before_filter :check_init
  
  def index
    #redirect_to campaign_home_url(Campaign.find(3))
    @campaigns = Campaign.all
    render 'theme/views/homepage'
  end
    
end
