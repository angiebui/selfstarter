module ProjectHelper

  @settings = Settings.find_by_id(1)
  
  def like_button(width = 70, show_faces = false)
    raw "<div class=\"fb-like\" data-send=\"false\" data-width=\"#{width}\" data-layout=\"button_count\" data-show-faces=\"#{show_faces}\"></div>"
  end
  def pin_it_button
    raw "<a href=\"http://pinterest.com/pin/create/button/?url=#{root_url}\" class=\"pin-it-button\"><img border=\"0\" src=\"//assets.pinterest.com/images/PinExt.png\" title=\"Pin It\" /></a>"
  end
  def tweet_button
    raw "<a href=\"https://twitter.com/share\" id=\"tweet_button\" class=\"twitter-share-button\" data-url=\"#{root_url}\" data-lang=\"en\" data-text=\"#{@settings.tweet_text}\">Tweet</a>"
  end

  def video_url
    "#{@settings.video_embed_url}?" + case @settings.video_embed_url
    when /vimeo/
      'title=0&byline=0&portrait=0&autoplay=0'
    when /youtube/
      'autohide=1&showinfo=0&rel=0&autoplay=0'
    else
      ''
    end
  end

  def encoded_root_url
    raw URI.encode "#{request.scheme}://#{request.host}/preorder"
  end

  def sold_out(payment_option)
    payment_option.limit > -1 and order_count(payment_option) >= payment_option.limit
  end

  def order_count(payment_option)
    Order.where(payment_option_id: payment_option).count(:token) # count of orders that have a token from amazon and are for this payment option
  end
end
