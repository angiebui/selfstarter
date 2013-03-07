Selfstarter.checkout =
  
  init: ->
    
    _this = this
    
    $('#amount_form').on "submit", (e) ->
      e.preventDefault()
      window.location = '/checkout/payment?' + 'amount=' + $(this).find('#amount').val()
    
    $('#table_quantity_value').on "change", (e) ->
      quantity = $(this).val()
      
      $amount = $('#amount')
      $fee = $('#fee')
      
      new_amount = parseFloat($amount.attr('data-original')) * quantity
      new_fee = parseFloat($fee.attr('data-original')) * quantity
      
      $fee.val(new_fee)
      $amount.val(new_amount)
      
      $('#table_fee').html('$' + new_fee.toFixed(2))
      $('#table_total').html('$' + (new_fee + new_amount).toFixed(2))
    
    $('#payment_form').on "submit", (e) ->
      e.preventDefault()
      $('.loader').show()
      $('button[type="submit"]').attr('disabled', true)
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
          $('#errors').append('<p>' + value + '</p>')
        $('.loader').hide()
        $('button[type="submit"]').attr('disabled', false)
      else
        user_id = $this.find('#ct_user_id').val()
        crowdtilt.card.create(user_id, cardData, _this.cardResponseHandler)   
  
  
  cardResponseHandler: (response) ->
    switch response.status
      when 201
        token = response.card.id
        input = $('<input name="ct_card_id" value="' + token + '" type="hidden" />');
        form = document.getElementById('payment_form')        
        form.appendChild(input[0])
        form.submit()          
      else 
         $('#errors').append('<p>An error occurred. Please try again.</p>')
         $('.loader').hide()
         $('button[type="submit"]').attr('disabled', false) 

    