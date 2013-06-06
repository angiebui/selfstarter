class UserMailer < ActionMailer::Base
  default from: Rails.configuration.reply_to_email
  
  def payment_confirmation(payment, campaign)
    @settings = Settings.find_by_id(1)
    @payment = payment
    @campaign = campaign
    mail to: @payment.email, subject: 'You just made a payment!'
  end
end