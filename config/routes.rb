Rails.application.routes.draw do
  resources :messages do
    member do
      post :ai_generate
      post :ai_chat
    end
  end

  get "chat" => "messages#chat"
  post "answer" => "messages#answer"
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Defines the root path route ("/")
  # root "posts#index"
end
