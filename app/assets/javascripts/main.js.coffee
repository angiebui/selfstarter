$ ->
  Selfstarter.init()
  Selfstarter.admin.init()
  Selfstarter.checkout.init()
  crowdtilt.init();
  $("#email").focus() if $('.payment_options').length == 0