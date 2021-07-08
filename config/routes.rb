Rails.application.routes.draw do
  resources :promotions
  resources :products
  get 'stock/index'
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
