Selfstarter::Application.routes.draw do
  mount Ckeditor::Engine => '/ckeditor'

  devise_for :users, path: 'account'

  root                     to: 'project#homepage'
  match '/checkout',       to: 'project#checkout',       via: :get,  as: :checkout
  match '/ajax/checkout',  to: 'project#ajax_checkout',  via: :post
  
  match '/admin/project',  to: 'admin#admin_project',                as: :admin_project
  
  match '/share/:uuid',    to: 'project#share',          via: :get,  as: :share
  match '/ipn',            to: 'project#ipn',            via: :post, as: :ipn  
  match '/prefill',        to: 'project#prefill',                    as: :prefill
  match '/postfill',       to: 'project#postfill',                   as: :postfill

  match '/start',          to: 'start#start',                        as: :start
  match '/start/init',     to: 'start#start_init',                   as: :start_init  
  
end
