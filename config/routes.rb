Rails.application.routes.draw do
  resources :stocks
  resources :promotions
  resources :products
  root 'stocks#index'
  post 'stocks/get_data'
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  Rails.application.routes.draw do
    namespace 'api' do
      namespace 'v1' do
        resources :stocks
      end
    end
  end
end
