Rails.application.routes.draw do
  resources :clues do
  	resources :answers
  end

  root 'home#index'
end
