require 'sidekiq/web'
Cachepig::Application.routes.draw do
  resources :caches
  # if you want sidekiq admin. You have to protect this in production!
  # mount Sidekiq::Web => '/sidekiq'
end
