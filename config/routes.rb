require 'resque/server'

Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  resources :slack, only: [:index] do
    collection do
      get :oauth_callback
      post :commands
      post :interactive_messages
    end
  end

  mount Resque::Server.new, at: "/resque"
end
