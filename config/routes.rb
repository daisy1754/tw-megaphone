Rails.application.routes.draw do
  get '/auth/twitter/callback', to: 'sessions#create'
  get '/logout', to:   'sessions#destroy'
  resources :followers, only: [:index] do
    collection do
      get :search
    end
  end

  root 'home#top'
end
