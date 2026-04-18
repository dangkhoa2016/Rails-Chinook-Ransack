Rails.application.routes.draw do
  devise_for :users, controllers: {
    sessions: 'users/sessions',
    registrations: 'users/registrations'
  }
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  resources :tracks do
    collection do
      get :json_list_for_select_element
    end
  end

  resources :playlists

  resources :playlist_tracks

  resources :invoices do
    collection do
      get :json_list_for_select_element
    end
  end

  resources :invoice_lines do
    collection do
      get :json_list_for_select_element
    end
  end

  resources :media_types do
    collection do
      get :json_list_for_select_element
    end
  end

  resources :genres do
    collection do
      get :json_list_for_select_element
    end
  end

  resources :employees do
    collection do
      get :json_list_for_select_element
    end
  end

  resources :customers do
    collection do
      get :json_list_for_select_element
    end
  end

  resources :artists do
    collection do
      get :json_list_for_select_element
    end
  end

  resources :albums do
    collection do
      get :json_list_for_select_element
    end
  end

  namespace :bulk_actions do
    namespace :albums do
      resources :bulk_destroy, only: [:new, :create]
      resources :bulk_edit, only: [:new, :create]
    end

    namespace :artists do
      resources :bulk_destroy, only: [:new, :create]
      resources :bulk_edit, only: [:new, :create]
    end

    namespace :customers do
      resources :bulk_destroy, only: [:new, :create]
      resources :bulk_edit, only: [:new, :create]
    end

    namespace :employees do
      resources :bulk_destroy, only: [:new, :create]
      resources :bulk_edit, only: [:new, :create]
    end

    namespace :genres do
      resources :bulk_destroy, only: [:new, :create]
      resources :bulk_edit, only: [:new, :create]
    end

    namespace :invoice_lines do
      resources :bulk_destroy, only: [:new, :create]
      resources :bulk_edit, only: [:new, :create]
    end

    namespace :invoices do
      resources :bulk_destroy, only: [:new, :create]
      resources :bulk_edit, only: [:new, :create]
    end

    namespace :media_types do
      resources :bulk_destroy, only: [:new, :create]
      resources :bulk_edit, only: [:new, :create]
    end

    namespace :playlists do
      resources :bulk_destroy, only: [:new, :create]
      resources :bulk_edit, only: [:new, :create]
      # resources :bulk_add_tracks, only: [:new, :create]
      # resources :bulk_remove_tracks, only: [:new, :create]
    end

    namespace :tracks do
      resources :bulk_destroy, only: [:new, :create]
      resources :bulk_edit, only: [:new, :create]
    end

  end

  namespace :tools do
    resources :filters, only: [:index]
    # resources :bulk_actions, only: [:new, :create], controller: 'tools/bulk_actions'
    resources :offcanvas, only: [] do
      collection do
        get :display_settings
        get :bulk_actions
      end
    end

    resources :bulk_edit, only: [:index]
  end

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get 'up' => 'rails/health#show', as: :rails_health_check

  # Defines the root path route ('/')
  root 'home#index'
end
