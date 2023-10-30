Rails.application.routes.draw do
  # Health check route
  get 'up' => 'rails/health#show', as: :rails_health_check

  resources :users
resources :comments
resources :likes
resources :posts

  root "posts#index"
end
