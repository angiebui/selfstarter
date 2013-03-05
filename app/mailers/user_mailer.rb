class UserMailer < ActionMailer::Base
  default from: "marc@msaint.com"
  
  def payment_confirmation(payment)
    @settings = Settings.find_by_id(1)
    @payment = payment
    mail to: @payment.user.email, subject: 'You just made a payment!'
  end
end