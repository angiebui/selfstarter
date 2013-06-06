class Api::V0::CampaignsController < Api::V0::BaseController
  def show
    render json: Campaign.find_by_slug!(params[:campaign_id])
  end
end