window.Selfstarter =

  init: ->
    $('.show_loader').on "click", ->
      $this = $(this)
      target = $this.attr('data-loader')
      $('.loader').filter('[data-loader="' + target + '"]').show()

$ ->
  Selfstarter.init()
  Selfstarter.project.init()
  Selfstarter.admin.init()
  Selfstarter.checkout.init()
  crowdtilt.init(crowdtilt_mode);
  $("#email").focus() if $('.payment_options').length == 0