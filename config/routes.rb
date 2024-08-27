Rails.application.routes.draw do
  get 'dashboard', to: 'dashboard#index'
  get 'dashboard/:id', to: 'dashboard#show', as: 'ticket'

  post 'messages/inbound', to: 'messages#inbound'
  post 'messages/reply', to: 'messages#reply', as: 'reply_messages'
  post 'messages/status', to: 'messages#status'

  get "up" => "rails/health#show", as: :rails_health_check

  root to: 'dashboard#index'
end
