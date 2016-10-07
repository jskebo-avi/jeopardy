Rails.application.routes.draw do
  resources :clues do
  	resources :answers
  end

  post 'answers/evaluate'
  post 'answers/get_user_score'
  root 'home#index'
end
