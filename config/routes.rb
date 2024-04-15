Rails.application.routes.draw do
  root "todos#index"
  get "/refresh", to: "todos#refresh", as: :refresh_todos
end
