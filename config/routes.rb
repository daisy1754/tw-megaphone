Rails.application.routes.draw do
  get '/auth/twitter/callback', to: 'sessions#create'
  get '/logout', to:   'sessions#destroy'
  resources :followers, only: [:index] do
    collection do
      get :search
      get :list
      get :sync_progress
      get :ranking_progress
    end
  end
  resources :dms, only: [:new, :create, :show]
  resources :rules, only: [:create, :destroy]

  root 'home#top'
end
