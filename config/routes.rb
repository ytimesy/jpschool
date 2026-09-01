Rails.application.routes.draw do
  root to: 'home#index'
  get '/login', to: 'sessions#new'
  get '/initial-setup', to: 'initial_setup#index'

  resources :lessons, only: [:index, :show] do
    get 'quiz', to: 'quizzes#show'
    post 'quiz', to: 'quizzes#results'
    get 'results', to: 'quizzes#results'
  end

  get '/review', to: 'reviews#index'
  get '/reviews', to: redirect('/review')
  get '/progress', to: 'progress#index'
  get '/settings', to: 'settings#index'
  get '/basic-policy', to: 'pages#basic_policy'
  get '/terms', to: 'pages#terms'
  get '/company', to: 'pages#company'

  namespace :admin do
    root to: 'dashboard#index'
    resources :users, only: [:index, :show]
    resources :lessons, only: [:index, :show] do
      member do
        get :preview
      end
    end
    get '/progress', to: 'progress#index'
  end
end
