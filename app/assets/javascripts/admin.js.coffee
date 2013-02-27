Selfstarter.admin = 

  init: ->

    $('a.show-loader').on "click", ->
      $('#header-loader').show()
  
    $('form#edit_settings_1').on "submit", ->
      $('#form-loader').show()
  
    $('input[name="settings[media_type]"]').on "change", ->
      $('#video-options').slideToggle()
      $('#image-options').slideToggle()
    
    $('input#settings_payment_type_any').on "change", ->
      $('#preset-amount').slideUp()
      $('#min-amount').slideUp()
    
    $('input#settings_payment_type_fixed').on "change", ->
      $('#min-amount').slideUp()
      $('#preset-amount').slideDown()
  
    
    $('input#settings_payment_type_min').on "change", ->
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