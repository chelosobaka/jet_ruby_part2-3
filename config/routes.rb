Rails.application.routes.draw do
  ActiveAdmin.routes(self)
  root 'orders#new'
  resources :orders, only: %i[new create show]
end
