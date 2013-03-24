class CampaignsController < ApplicationController

  def homepage
    @campaign = Campaign.find(params[:id])
    @ct_campaign = Crowdtilt::Campaign.find(@campaign.ct_campaign_id)
    @faqs = Faq.all
    render 'theme/views/campaign'
  end

end
