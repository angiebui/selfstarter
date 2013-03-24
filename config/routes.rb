Selfstarter::Application.routes.draw do
  
  mount Ckeditor::Engine => '/ckeditor'

  devise_for :users, { path: 'account', controllers: { registrations: :registrations } }  do 
    match '/user/settings',         to: 'devise/registrations#edit',    as: :user_settings 
  end

  root                               to: 'project#homepage'
  match '/checkout/amount',          to: 'project#checkout_amount',         via: :get,  as: :checkout_amount
  match '/checkout/payment',         to: 'project#checkout_payment',                    as: :checkout_payment
  match '/checkout/confirmation',    to: 'project#checkout_confirmation',               as: :checkout_confirmation

  match '/admin/website',            to: 'admin#admin_website',         as: :admin_website
  
  namespace :admin do
    resources :campaigns
  end
 
 
  #get   '/admin/campaigns',            to: 'admin#campaigns_list',    as: :admin_campaigns_list
  #get   '/admin/campaigns/new',        to: 'admin#campaigns_new',     as: :admin_campaigns_new
  #post  '/admin/campaigns',            to: 'admin#campaigns_create',  as: :admin_campaigns_create
  #get   '/admin/campaigns/:id/edit',   to: 'admin#campaigns_edit',    as: :admin_campaigns_edit
  #put   '/admin/campaigns/:id',        to: 'admin#campaigns_update',  as: :admin_campaigns_update
  
  match '/admin/bank-setup',                         to: 'admin#admin_bank_setup',      as: :admin_bank_setup
  match '/ajax/verify',                              to: 'admin#ajax_verify',           as: :ajax_verify

  match '/user/payments',           to: 'user#payments',                               as: :user_payments
  
  
  match '/share/:uuid',             to: 'project#share',                   via: :get,  as: :share
  match '/ipn',                     to: 'project#ipn',                     via: :post, as: :ipn  
  match '/prefill',                 to: 'project#prefill',                             as: :prefill
  match '/postfill',                to: 'project#postfill',                            as: :postfill

  match '/:id',                     to: 'campaigns#homepage',                          as: :campaign_home
end
