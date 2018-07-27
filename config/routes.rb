Rails.application.routes.draw do
  get 'simple_pages/rules'
  root 'simple_pages#index'
  put 'games/:id/set_stone', to: 'games#set_stone'
  put 'games/:id/undo', to: 'games#undo'
  resources :games, only: [:index, :show, :create, :destroy]
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end