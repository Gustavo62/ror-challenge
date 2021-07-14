Rails.application.routes.draw do 
  scope "(:locale)", locale: /#{I18n.available_locales.join("|")}/ do 
    resources :stocks
    resources :promotions
    resources :products
    root to: 'stocks#index'
    post 'stocks/get_data' 
  end
  Rails.application.routes.draw do
    namespace 'api' do
      namespace 'v1' do
        resources :stocks 
      end
    end
  end
end
