Selfstarter::Application.routes.draw do
  devise_for :users, path: 'account', controllers: { registrations: "registrations" }

  root                     to: 'project#index'
  
  match '/checkout',       to: 'project#checkout',       via: :get,  as: :checkout
  match '/ajax/checkout',  to: 'project#ajax_checkout',  via: :post
  
  match '/admin/project',  to: 'project#admin_project',              as: :admin_project
  
  
  
  match '/share/:uuid',    to: 'project#share',          via: :get,  as: :share
  match '/ipn',            to: 'project#ipn',            via: :post, as: :ipn  
  match '/prefill',        to: 'project#prefill',                    as: :prefill
  match '/postfill',       to: 'project#postfill',                   as: :postfill
  
  
end
