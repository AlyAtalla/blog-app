Rails.application.routes.draw do
  root "users#index"
  resources :users, only: [:index, :show] do
    resources :posts, only: [:index, :show, :create, :new] do
      resources :comments, only: [:index, :show, :create]
      post "like", on: :member
    end
  end

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check
end
