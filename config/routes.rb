TimeTracker::Application.routes.draw do
  get "welcome/index"

  devise_for :users, :controllers => { :registrations => "registrations" }
  
  namespace :admin do
    resources :users
  end
  
  resources :users, only: :index do
    put 'set_employee_hourly_rate', action: 'set_employee_hourly_rate'
    match 'get_total_earnings(/:from(/:to))', action: 'get_total_earnings', as: 'get_total_earnings'
  end

  resources :users do
    get :autocomplete_user_email, :on => :collection
  end

  resources :tasks do
    collection do
      get :download
    end
  end

  resources :projects do
    resources :tasks do
      member do
        get :start_work
        get :stop_work
      end
    end
    resources :time_log_entries

    put '/budget', action: 'set_budget'
    put '/currency', action: 'set_currency'
    put 'client_rate/:user_id', action: 'set_client_hourly_rate', as: 'set_client_hourly_rate'
  end

  post '/add_owner', :to => 'projects#add_owner'
  match '/projects/:project_id/owners(/:email)', :to => 'projects#remove_owner',
                                        :as => :remove_owner, :method => :delete

  resources :time_log_entries
  resources :reports, only: :index do
    collection do
      get :pivot
    end
  end

  post 'tasks/tasks_by_project'
  post 'time_log_entries/user_task_entries'
  post '/pivotal_web_hook', :to => "webHooks#pivotal_activity_web_hook"

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

  root to: "tasks#welcome"

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id(.:format)))'
end
