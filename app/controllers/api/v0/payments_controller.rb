class Api::V0::PaymentsController < Api::V0::BaseController
  def index
    campaign = Campaign.find_by_slug!(params[:campaign_id])
    render json: campaign.payments
  end
end