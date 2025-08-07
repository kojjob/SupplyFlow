Rails.application.routes.draw do
  resources :order_items
  resources :orders
  # Devise routes for authentication
  devise_for :users, controllers: {
    sessions: "users/sessions",
    registrations: "users/registrations",
    passwords: "users/passwords",
    confirmations: "users/confirmations"
  }

  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Organizations and Locations
  resources :organizations, only: [ :create ]
  resources :locations

  # User Management
  resources :users do
    member do
      patch "activate"
      patch "deactivate"
      post "reset_password"
    end
  end

  # Products and Inventory
  resources :products

  # Blog Posts and Reviews
  resources :posts, param: :slug do # Use slug for posts
    resources :reviews, only: [:create, :edit, :update, :destroy]
    member do
      patch :publish
      patch :archive
    end
  end

  # Inventory Management
  get "inventory" => "inventory#index", as: :inventory
  get "inventory/transactions" => "inventory#transactions", as: :inventory_transactions
  get "inventory/report" => "inventory#report", as: :inventory_report
  post "inventory/:id/adjust" => "inventory#adjust", as: :adjust_inventory
  post "inventory/:id/transfer" => "inventory#transfer", as: :transfer_inventory

  # Inventory Adjustments
  resources :inventory_adjustments do
    member do
      post :approve
      post :reject
    end
    collection do
      get :pending
    end
  end

  # Batch Inventory routes
  resources :batch_inventories, only: [] do
    collection do
      get 'new_csv'
      post 'create_csv'
      get 'new_manual'
      post 'create_manual'
    end
  end

  # Suppliers and Customers
  resources :suppliers
  resources :customers

  # Orders
  resources :orders do
    member do
      post :cancel
      post :ship
      post :deliver
      post :return
      get :invoice
    end

    collection do
      get :pending
      get :completed
    end
  end

  resources :purchase_orders do
    member do
      post "receive_items"
    end
  end

  resources :sales_orders do
    member do
      post "ship_items"
    end
  end

  # Payments
  resources :payments

  # Dashboard
  get "dashboard" => "dashboard#index", as: :dashboard

  # Notifications
  resources :notifications, only: [:index] do
    post :mark_as_read, on: :member # For individual notifications: /notifications/:id/mark_as_read
    post :mark_all_as_read, on: :collection # For all notifications: /notifications/mark_all_as_read
  end

  # Settings
  get "settings/profile" => "settings#profile", as: :settings_profile
  get "settings/account" => "settings#account", as: :settings_account
  get "settings/notifications" => "settings#notifications", as: :settings_notifications
  get "settings/appearance" => "settings#appearance", as: :settings_appearance
  get "settings/security" => "settings#security", as: :settings_security
  get "settings/organization" => "settings#organization", as: :settings_organization
  get "settings/users" => "settings#users", as: :settings_users
  get "settings/integrations" => "settings#integrations", as: :settings_integrations

  # Settings Updates
  patch "settings/profile" => "settings#update_profile", as: :update_profile
  patch "settings/account" => "settings#update_account", as: :update_account
  patch "settings/notifications" => "settings#update_notifications", as: :update_notifications
  patch "settings/appearance" => "settings#update_appearance", as: :update_appearance
  patch "settings/organization" => "settings#update_organization", as: :update_organization

  # API Endpoints
  namespace :api do
    namespace :v1 do
      # Authentication API
      post "auth/token", to: "auth#token"
      get "auth/verify", to: "auth#verify"
      post "auth/refresh", to: "auth#refresh"

      # User API
      get "users/profile", to: "users#profile"
      patch "users/profile", to: "users#update_profile"
      get "users/activity", to: "users#activity"

      # Products API
      resources :products, only: [ :index, :show, :create, :update ] do
        get "inventory", on: :member
      end

      # API endpoints for order-related AJAX requests

      resources :customers, only: [ :show ]
      resources :products, only: [ :show ]


      # Inventory API
      resources :inventory, only: [ :index, :show, :create, :update ] do
        collection do
          post "transfer"
        end
      end

      # Locations API
      resources :locations, only: [ :index, :show, :create, :update ]

      # Suppliers API
      resources :suppliers

      # Customers API
      resources :customers

      # Purchase Orders API
      resources :purchase_orders do
        member do
          post "receive_items"
          post "cancel"
        end
      end

      # Sales Orders API
      resources :sales_orders do
        member do
          post "ship_items"
          post "cancel"
          get "payments"
        end
      end

      # Payments API
      resources :payments, only: [ :index, :show, :create ]

      # Dashboard API
      get "dashboard", to: "dashboard#index"
      get "dashboard/sales_summary", to: "dashboard#sales_summary"
      get "dashboard/inventory_summary", to: "dashboard#inventory_summary"
      get "dashboard/recent_activities", to: "dashboard#recent_activities"

      # Settings API
      get "settings/organization", to: "settings#organization"
      patch "settings/organization", to: "settings#update_organization"
      get "settings/users", to: "settings#users"

      # Reports API
      get "reports/sales", to: "reports#sales"
      get "reports/inventory", to: "reports#inventory"
      get "reports/suppliers", to: "reports#suppliers"
    end
  end

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Offline page for PWA
  get "offline" => "pages#offline", as: :offline

  # Test page for swipe gestures
  get "swipe-test" => "pages#swipe_test", as: :swipe_test

  # About, Contact, and Support pages
  get "setup-guide" => "pages#setup_guide", as: :setup_guide
  get "about" => "pages#about", as: :about
  get "contact" => "pages#contact", as: :contact
  get "support" => "pages#support", as: :support
  # get "setup-guide" => "pages#setup_guide", as: :setup_guide
  get "documentation" => "pages#documentation", as: :documentation

  # SEO Sitemaps
  get "sitemap.xml" => "sitemaps#index", defaults: { format: :xml }
  get "sitemap-main.xml" => "sitemaps#main", defaults: { format: :xml }
  get "sitemap-posts.xml" => "sitemaps#posts", defaults: { format: :xml }
  get "sitemap-categories.xml" => "sitemaps#categories", defaults: { format: :xml }
  get "sitemap-images.xml" => "sitemaps#images", defaults: { format: :xml }

  # Defines the root path route ("/")
  root "pages#index"
end
