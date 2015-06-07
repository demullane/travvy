Rails.application.routes.draw do

  root 'home#search'

  match 'auth/:provider/callback', to: 'sessions#create', via: [:get, :post]
  match 'auth/failure', to: redirect('/'), via: [:get, :post]
  match 'signout', to: 'sessions#destroy', as: 'signout', via: [:get, :post]

  get '/map' => 'home#map'
  get '/listings' => 'results#listings'

end
