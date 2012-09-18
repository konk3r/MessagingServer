Smessage::Application.routes.draw do
  root :to => 'home#index'
  
  post 'login' => 'sessions#create'
  delete 'logout' => 'sessions#destroy'
  
  post 'user/sign_up' => 'users#create'
  delete 'user/delete' => 'users#destroy'
  
  get 'user/:id/contacts' => 'contacts#show'
  post 'user/:id/contact/:contact_username/' => 'contacts#create'
  put 'user/:id/contact/:contact_id/' => 'contacts#update' #accept => true
  delete 'user/:id/contact/:contact_id/' => 'contacts#destroy'
  
  post 'user/:id/contact/:contact_id/message' => 'messages#create'
  get 'user/:id/contact/:contact_id/messages/' => 'messages#show'
  

  # The priority is based upon order of creation:
  # first created -> highest priority.

  # Sample of regular route:
  #   match 'products/:id' => 'catalog#view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   match 'products/:id/purchase' => 'catalog#purchase', :as => :purchase
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Sample resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Sample resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Sample resource route with more complex sub-resources
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', :on => :collection
  #     end
  #   end

  # Sample resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id))(.:format)'
end
