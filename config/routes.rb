Selfstarter::Application.routes.draw do
  mount Ckeditor::Engine => '/ckeditor'
  
  devise_for :users, { path: 'account', controllers: { registrations: :registrations } }  do 
    match '/user/settings',         to: 'devise/registrations#edit',    as: :user_settings 
  end

  root                              to: 'project#homepage'
  match '/checkout',                to: 'project#checkout',                via: :get,  as: :checkout
  match '/checkout/payment',        to: 'project#checkout_payment',                    as: :checkout_payment
  match '/checkout/confirmation',   to: 'project#checkout_confirmation',               as: :checkout_confirmation
  
  match '/admin/project',           to: 'admin#admin_project',                         as: :admin_project
  match '/admin/contributors',      to: 'admin#admin_contributors',                    as: :admin_contributors
  match '/admin/bank-setup',        to: 'admin#admin_bank_setup',                      as: :admin_bank_setup
  match '/ajax/verify',             to: 'admin#ajax_verify',                           as: :ajax_verify

  match '/user/payments',           to: 'user#payments',                               as: :user_payments
  
  
  match '/share/:uuid',             to: 'project#share',                   via: :get,  as: :share
  match '/ipn',                     to: 'project#ipn',                     via: :post, as: :ipn  
  match '/prefill',                 to: 'project#prefill',                             as: :prefill
  match '/postfill',                to: 'project#postfill',                            as: :postfill
end
