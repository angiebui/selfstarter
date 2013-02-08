Selfstarter::Application.routes.draw do
  devise_for :users, path: '', path_names: { sign_in: 'signin', sign_out: 'signout', sign_up: 'signup' }

  root                    to: 'project#index'
  
  match '/checkout',      to: 'project#checkout',   via: :get,  as: :checkout
  match '/share/:uuid',   to: 'project#share',      via: :get,  as: :share
  match '/ipn',           to: 'project#ipn',        via: :post, as: :ipn  
  match '/prefill',       to: 'project#prefill',                as: :prefill
  match '/postfill',      to: 'project#postfill',               as: :postfill
end
