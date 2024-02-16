Rails.application.routes.draw do
  root 'orders#new'
  resources :orders, only: %i[new create show]
end
