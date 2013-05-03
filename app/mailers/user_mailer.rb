class UserMailer < ActionMailer::Base
  default from: "no-reply@crowdhoster.com"
  
  def payment_confirmation(payment)
    @settings = Settings.find_by_id(1)
    @payment = payment
    mail to: @payment.email, subject: 'You just made a payment!'
  end
end