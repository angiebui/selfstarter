window.Selfstarter =

  init: ->
    $('.show_loader').on "click", ->
      $this = $(this)
      target = $this.attr('data-loader')
      $('.loader').filter('[data-loader="' + target + '"]').show()
    
    $('.show_tooltip').tooltip()

$ ->
  crowdtilt_mode = crowdtilt_mode || 'sandbox'  
  Selfstarter.init()
  Selfstarter.admin.init()
  Selfstarter.campaigns.init()
  Selfstarter.theme.init()
  crowdtilt.init(crowdtilt_mode)
