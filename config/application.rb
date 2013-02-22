require File.expand_path('../boot', __FILE__)

require 'rails/all'

if defined?(Bundler)
  Bundler.require(*Rails.groups(:assets => %w(development test)))
end

module Selfstarter
  
  class Application < Rails::Application

    # --- Standard Rails Config ---
    config.time_zone = 'Pacific Time (US & Canada)'
    config.encoding = "utf-8"
    config.filter_parameters += [:password]
    config.active_record.whitelist_attributes = true
    # Enable the asset pipeline
    config.assets.enabled = true
    # Version of your assets, change this if you want to expire all your assets
    config.assets.version = '1.0'
    # --- Standard Rails Config ---
    
    #Crowdtilt API key/secret
    config.crowdtilt_key = "63fccb7868c5f018c167a44d9f6540"
    config.crowdtilt_secret = "76d8019033728a7a8d7222fcf288fefcd13f316c"
    
    #Fix for getting Devise to work on Heroku deploy
    #Forcing app to not access the DB or models when precompiling
    config.assets.initialize_on_precompile = false
  end
end