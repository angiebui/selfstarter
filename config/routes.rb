Selfstarter::Application.routes.draw do
  root                    to: 'project#index'
  
  match '/checkout',      to: 'project#checkout',   via: :get,  as: :checkout
  match '/share/:uuid',   to: 'project#share',      via: :get,  as: :share
  match '/ipn',           to: 'project#ipn',        via: :post, as: :ipn  
  match '/prefill',       to: 'project#prefill',                as: :prefill
  match '/postfill',      to: 'project#postfill',               as: :postfill
end
