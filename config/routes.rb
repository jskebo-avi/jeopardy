Rails.application.routes.draw do
  resources :clues do
  	resources :answers
  end

  post 'answers/correct'
  root 'home#index'
end
