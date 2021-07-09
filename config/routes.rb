Rails.application.routes.draw do
  resources :stocks
  resources :promotions
  resources :products
  root 'stocks#index'
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
