Rails.application.routes.draw do
  root 'web#index'
  get '/web', to: 'web#index'
  namespace :api do
    namespace :v1 do
      resources :newpokers
    end
  end
end
