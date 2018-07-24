Rails.application.routes.draw do
  get 'simple_pages/rules'
  root 'simple_pages#index'
  resources :games, only: [:index, :show, :new, :create, :destroy]
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
