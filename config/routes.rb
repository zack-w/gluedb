Gluedb::Application.routes.draw do

  devise_for :users, :path => "accounts"

  root :to => 'dashboards#index'

  get "dashboards/index"
  get "welcome/index"
  get "tools/premium_calc"
  get "flatuipro_demo/index"

  namespace :admin do
    namespace :settings do
      resources :hbx_policies
    end
    resources :users
  end

  resources :enrollment_addresses

  resources :plan_metrics, :only => :index

  resources :vocab_uploads, :only => [:new, :create]

  resources :enrollment_transmission_updates, :only => :create

  resources(:change_vocabularies, :only => [:new, :create]) do
    collection do
      get 'download'
    end
  end

  resources :edi_transaction_set_payments
  resources :edi_transaction_sets
  resources :edi_transmissions

  resources :enrollments do
    member do
      get :canonical_vocabulary
    end
  end

  resources :application_groups do
    resources :households
    get 'page/:page', :action => :index, :on => :collection
  end
    
  resources :users
  resources :policies

  resources :individuals 
  resources :people do
    get 'page/:page', :action => :index, :on => :collection
    member do
      put :compare
      put :persist_and_transmit
      put :assign_authority_id
    end
  end

  resources :employers do
    get 'page/:page', action: :index, :on => :collection
    member do
      get :group
    end
    resources :employees, except: [:destroy], on: :member do
      member do
        put :compare
        put :terminate
      end
    end
  end

  resources :brokers do
    get 'page/:page', :action => :index, :on => :collection
  end

  resources :carriers do
    resources :plans
    get :show_plans
    post :calculate_premium, on: :collection  
  end

  resources :plans, only: [:index, :show] do
    member do
      get :calculate_premium
    end
  end

  resources :policies, only: [:show]

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
