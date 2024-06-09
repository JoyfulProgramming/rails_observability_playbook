Rails.application.routes.draw do
  devise_for :users
  get "users/show"
  get "user/show"
  root "todos#index"
  get "/refresh", to: "todos#refresh", as: :refresh_todos
  resources :users, only: :show
end
