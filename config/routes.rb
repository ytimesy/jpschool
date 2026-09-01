Rails.application.routes.draw do
  root to: 'home#index'
  resources :lessons, only: [:index]
end
