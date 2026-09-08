Rails.application.routes.draw do
  root to: 'home#index'
  get '/login', to: 'sessions#new'
  post '/auth/google_oauth2', to: 'sessions#google_start', as: :google_login
  match '/auth/:provider/callback', to: 'sessions#create', via: [:get, :post], as: :auth_callback
  match '/auth/failure', to: 'sessions#failure', via: [:get, :post]
  delete '/logout', to: 'sessions#destroy'
  get '/initial-setup', to: 'initial_setup#index'

  resources :lessons, only: [:index, :show] do
    patch 'self-assessment', to: 'self_assessments#update'
    get 'quiz', to: 'quizzes#show'
    post 'quiz', to: 'quizzes#results'
    get 'results', to: 'quizzes#results'
  end

  get '/review', to: 'reviews#index'
  get '/reviews', to: redirect('/review')
  get '/progress', to: redirect('/evaluation')
  get '/evaluation', to: 'evaluations#show'
  get '/evaluation/certificate', to: 'evaluations#certificate', as: :evaluation_certificate
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
