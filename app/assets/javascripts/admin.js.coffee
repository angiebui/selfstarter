Selfstarter.admin = 

  init: ->
  
    _this = this

    #
    # Admin Project
    #
  
    $('form.edit_campaign').on "submit", ->
      $('#form-loader').show()
  
    $('input[name="campaign[media_type]"]').on "change", ->
      $('#video-options').slideToggle()
      $('#image-options').slideToggle()
    
    $('input#campaign_payment_type_any').on "change", ->
      $('#preset-amount').slideUp()
      $('#min-amount').slideUp()
    
    $('input#campaign_payment_type_fixed').on "change", ->
      $('#min-amount').slideUp()
      $('#preset-amount').slideDown()  
    
    $('input#campaign_payment_type_min').on "change", ->
      $('#preset-amount').slideUp()
      $('#min-amount').slideDown()
      
    $('.faq.sortable').sortable
      stop: (e, ui) ->
        iterator = 1
        $.each $('.faq.sortable li'), ->
          $this = $(this)
          $this.find('span').html(iterator)
          iterator++      
  
    $('#faq-add').on 'click', ->
      $element = $('.faq.sortable li:last-child').clone()
      position = parseInt($element.find('span').html(), 10) + 1
      $element.find('span').html(position)
      $element.find('textarea[name="faq[][question]"]').html('')
      $element.find('textarea[name="faq[][answer]"]').html('')
      $element.appendTo('.faq.sortable')  
    
    $('.faq.sortable').on 'click', (e) ->    
        $this = $(e.target)
        if $this.is('.faq-delete')
          e.preventDefault()
          $this.parent().remove()
          iterator = 1
          $.each $('.faq.sortable li'), ->
            $this = $(this)
            $this.find('span').html(iterator)
            iterator++
            
    #
    # Admin Bank Setup
    #

    $('#bank_form').on "submit", (e) ->
      e.preventDefault()
      $('.loader').show()
      $('#errors').html('')        
      $this = $(this)
      
      userData = 
        name: $this.find('#full_legal_name').val()
        phone: $this.find('#phone').val()
        street_address: $this.find('#street_address').val()
        postal_code: $this.find('#zip').val()                
        dob: $this.find('#birth_year').val() + '-' + $this.find('#birth_month').val()
        
      $.ajax '/ajax/verify',
        type: 'POST'
        data: userData
        beforeSend: (jqXHR, settings) ->
          # Devise requires the CSRF token in order to still recognize the current user
          jqXHR.setRequestHeader('X-CSRF-Token', $('meta[name="csrf-token"]').attr('content'))         
        success: (data) ->
          if(data == "success")
            _this.createBankAccount($this)
          else
            $('#errors').append('<p>An error occurred, please re-enter your account information</p>')
            $('.loader').hide() 
  
  
  # Custom Functions
  
  createBankAccount: ($form) ->
    bankData =
      account_number: $form.find('#account_number').val()
      name: $form.find('#bank_routing_number').val()
      bank_code: $form.find('#bank_routing_number').val()
    
    errors={}
    if !crowdtilt.bank.validateUSARoutingNumber(bankData.bank_code)
      errors["bank_routing_number"] = "Invalid routing number"
    if bankData.account_number == ''
      errors["bank_account_number"] = "Invalid account number"
    
    if !$.isEmptyObject(errors)
      $.each errors, (index, value) -> 
        $('#errors').append('<p>' + value + '</p>')
      $('.loader').hide()
    else
      user_id = $form.find('#ct_user_id').val()
      crowdtilt.bank.create(user_id, bankData, Selfstarter.admin.bankResponseHandler)   
  
  
  bankResponseHandler: (response) ->
    switch response.status
      when 201
        token = response.bank.id
        input = $('<input name="ct_bank_id" value="' + token + '" type="hidden" />');
        form = document.getElementById('bank_form')        
        form.appendChild(input[0])
        form.submit()          
      else 
         $('#errors').append('<p>An error occurred. Please try again.</p>')
         $('.loader').hide() 