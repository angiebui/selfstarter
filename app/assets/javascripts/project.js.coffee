Selfstarter =
  firstTime: true
  payment_amount: 0
  validateEmail: ->
    # The regex we use for validating email
    # It probably should be a parser, but there isn't enough time for that (Maybe in the future though!)
    if /^([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})$/.test($("#email").val())
      $("#email").removeClass("highlight")
      $("#amazon_button").removeClass("disabled")
    else
      $("#email").addClass("highlight") unless Selfstarter.firstTime
      $("#amazon_button").addClass("disabled") unless $("#amazon_button").hasClass("disabled")
  
  cardResponseHandler: (response) ->
    console.log(response)
    response.amount = Selfstarter.payment_amount
    switch response.status
       when 201
        $.ajax '/ajax/checkout',
          type: 'POST'
          data: response
          beforeSend: (jqXHR, settings) ->
            # Devise requires the CSRF token in order to still recognize the current user
            jqXHR.setRequestHeader('X-CSRF-Token', $('meta[name="csrf-token"]').attr('content'))         
          success: (data) ->
            console.log(data)
       when 400 then console.log('Error')
       when 404 then console.log('Not Found')
       else console.log('Unknown Error')
  
  init: ->
    checkoutOffset = $('body').height() - $('.footer').outerHeight() #needs to be done upon init

    $("#email").bind "textchange", ->
      Selfstarter.validateEmail()
    $("#email").bind "hastext", ->
      Selfstarter.validateEmail()
    # The first time they type in their email, we don't want it to throw a validation error
    $("#email").change ->
      Selfstarter.firstTime = false

    # init placeholder image for video
    $("#video_image").on "click", ->
      $("#player").removeClass("hidden")
      $("#player").css('display', 'block')
      $(this).hide()
    
    $('#payment_form').on "submit", (e) ->
      e.preventDefault()
      $('#errors').html('')        
      $this = $(this)
      
      cardData =
        number: $this.find('#card_number').val()
        expiration_month: $this.find('#expiration_month').val()
        expiration_year: $this.find('#expiration_year').val()
        security_code: $this.find('#security_code').val()
      
      errors = crowdtilt.card.validate(cardData)
      if !$.isEmptyObject(errors)
        $.each errors, (index, value) -> 
          $('#errors').append('<p>' + value + '</p>');
      else
        Selfstarter.payment_amount = $('#amount').attr('data-amount')
        user_id = $this.find('#ct_user_id').val()
        crowdtilt.card.create(user_id, cardData, Selfstarter.cardResponseHandler)     

    # if they are using the optional payment options section on the checkout page, need to conditional fix the email
    # field and button to the bottom of the page so it's displayed after selecting a radio button
    if $('.payment_options').length > 0

      onScroll = () ->
        wrapper = $('.checkout_controls_wrapper')
        if $(window).scrollTop() + $(window).height() < checkoutOffset
          wrapper.addClass('fix_to_bottom')
        else if wrapper.hasClass("fix_to_bottom")
          wrapper.removeClass('fix_to_bottom')

      $(window).on "scroll", ->
        onScroll()

      # the radio button selection should bring up the email field and button
      $('.payment_options ol li').on "click", ->
        return false if $(this).children(".payment_radio").attr("disabled") == "disabled"
        $(".payment_radio").parents("ol>li").removeClass("checkout_option_selected")
        $(this).addClass("checkout_option_selected")
        $(this).children(".payment_radio").attr "checked", "checked"
        onScroll()
        $('.checkout_controls_wrapper').addClass "checkout_ready"
            
$ ->
  Selfstarter.init()
  params = {}
  params.server = 'https://api-sandbox.crowdtilt.com' 
  crowdtilt.init(params);
  $("#email").focus() if $('.payment_options').length == 0
