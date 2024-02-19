Rails.application.routes.draw do
  devise_for :users
  ActiveAdmin.routes(self)

  root 'orders#new'
  resources :users, only: :show do
    resources :orders, only: %i[index new create show]
  end
end
