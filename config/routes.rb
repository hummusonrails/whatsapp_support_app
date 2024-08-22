Rails.application.routes.draw do
  # Dashboard routes
  get 'dashboard', to: 'dashboard#index'
  get 'dashboard/tickets/:id', to: 'dashboard#show', as: 'ticket'

  # Messages routes
  post 'messages/inbound', to: 'messages#inbound' # Renamed from 'receive' to 'inbound'
  post 'messages/reply', to: 'messages#reply', as: 'reply_messages'
  post 'messages/status', to: 'messages#status' # New route for status updates via webhook

  # Health check route
  get "up" => "rails/health#show", as: :rails_health_check

  # Root route
  root to: 'dashboard#index'
end
