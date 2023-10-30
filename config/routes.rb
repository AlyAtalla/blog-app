Rails.application.routes.draw do
  # Health check route
  get 'up' => 'rails/health#show', as: :rails_health_check

  resources :users, only: [:index, :show] do
    resources :posts, only: [:index, :show]
  end

  resources :comments
  resources :likes
  root "posts#index"
end
