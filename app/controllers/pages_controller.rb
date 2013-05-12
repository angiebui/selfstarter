class PagesController < ApplicationController
  before_filter :check_init
  
  def index
    @campaigns = Campaign.all
    render 'theme/views/homepage'
  end
    
end
