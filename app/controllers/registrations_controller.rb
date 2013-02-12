class RegistrationsController < Devise::RegistrationsController
  
  #If the user is being registered from the checkout page, we want to drop them back on 
  #the checkout page
  def create
    if params[:location] == 'checkout'
      session["#{resource_name}_return_to"] = checkout_path
    end
    super
  end
end