Rails.application.routes.draw do
  devise_for :users, controllers: {sessions: 'users/sessions' }
  resources :users
  resources :clues do
  	resources :answers
  end

  get 'history', to: 'history#index'
  post 'answers/evaluate'
  post 'answers/get_user_score'
  post 'users/change_password'
  root 'home#index'
end
