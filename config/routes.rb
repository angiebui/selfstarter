Selfstarter::Application.routes.draw do
  
  mount Ckeditor::Engine => '/ckeditor'
  
  # PAGES
  root                                         to: 'pages#index'
  
  # USERS
  devise_for :users, { path: 'account', controllers: { registrations: :registrations } }  do 
    match '/user/settings',                    to: 'devise/registrations#edit',             as: :user_settings 
  end
  match '/user/payments',                      to: 'user#payments',                         as: :user_payments
  
  # ADMIN
  match '/admin/website',                      to: 'admin#admin_website',                   as: :admin_website
  namespace :admin do
    resources :campaigns
  end
  match '/admin/campaigns/:id/copy',           to: 'admin/campaigns#copy',                  as: :admin_campaigns_copy
  match '/admin/campaigns/:id/contributors',   to: 'admin/campaigns#contributors',          as: :admin_campaigns_contributors
  match '/admin/bank-setup',                   to: 'admin#admin_bank_setup',                as: :admin_bank_setup
  match '/ajax/verify',                        to: 'admin#ajax_verify',                     as: :ajax_verify

  # CAMPAIGNS  
  match '/:id/checkout/amount',                to: 'campaigns#checkout_amount',             as: :checkout_amount
  match '/:id/checkout/payment',               to: 'campaigns#checkout_payment',            as: :checkout_payment
  match '/:id/checkout/confirmation',          to: 'campaigns#checkout_confirmation',       as: :checkout_confirmation
  match '/:id',                                to: 'campaigns#home',                        as: :campaign_home
  
end
