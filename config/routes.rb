Rails.application.routes.draw do
  root to: 'home#index'
  resources :lessons, only: [:index, :show] do
    get 'quiz', to: 'quizzes#show'
    post 'quiz', to: 'quizzes#results'
    get 'results', to: 'quizzes#results'
  end

  get '/reviews', to: 'reviews#index'
  get '/progress', to: 'progress#index'
  get '/settings', to: 'settings#index'
end
