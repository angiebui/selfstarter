$ ->
  Selfstarter.init()
  Selfstarter.admin.init()
  Selfstarter.checkout.init()
  crowdtilt.init(crowdtilt_mode);
  $("#email").focus() if $('.payment_options').length == 0