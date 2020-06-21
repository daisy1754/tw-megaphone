Rails.application.routes.draw do
  get '/auth/twitter/callback', to: 'sessions#create'
  get '/logout', to:   'sessions#destroy'
  resources :followers, only: [:index] do
    collection do
      get :search
      get :list
      get :sync_progress
      get :ranking_progress
      post :export
    end
  end
  resources :dms, only: [:new, :create, :show] do
    collection do
      post :send_me
    end
  end
  resources :rules, only: [:create, :destroy]
  resources :emails, only: [:show] do
    get :optout
    post :save
  end

  root 'home#top'
end
