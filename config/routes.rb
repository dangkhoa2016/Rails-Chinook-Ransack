Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  resources :tracks
  resources :playlists
  resources :playlist_tracks
  resources :media_types
  resources :invoices
  resources :invoice_lines
  resources :genres
  resources :employees
  resources :customers
  resources :artists do
    collection do
      get :list_for_select
    end
  end
  resources :albums

  resources :filters, only: [:index], controller: 'tools/filters'

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get 'up' => 'rails/health#show', as: :rails_health_check

  # Defines the root path route ('/')
  root 'home#index'
end
