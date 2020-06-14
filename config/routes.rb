Rails.application.routes.draw do
  get '/auth/twitter/callback', to: 'sessions#create'
  get '/logout', to:   'sessions#destroy'

  root 'home#top'
end
