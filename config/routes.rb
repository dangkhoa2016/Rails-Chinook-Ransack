Rails.application.routes.draw do
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

  resources :filters, only: [:index], controller: 'tools/filters'

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get 'up' => 'rails/health#show', as: :rails_health_check

  # Defines the root path route ('/')
  root 'home#index'
end
