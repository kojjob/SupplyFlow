Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

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
  get "about" => "pages#about", as: :about
  get "contact" => "pages#contact", as: :contact
  get "support" => "pages#support", as: :support

  # Defines the root path route ("/")
  root "posts#index"
end
