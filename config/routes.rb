Rails.application.routes.draw do
  root 'welcome#index'
  constraints subdomain: "api.#{ENV['SUBDOMAIN']}", format: 'json' do
    namespace :api, path: '/v1/' do
      resources :projets, only: :show
    end
  end
  scope(path_names: { new: 'nouveau', edit: 'edition' }) do
    resources :projets, only: [:show, :edit, :update]

    get '/projets/:projet_id/invitations/operateur/:operateur_id', to: 'invitations#new', as: 'new_invitation'
    post '/projets/:projet_id/invitations/operateur/:operateur_id', to: 'invitations#create'
    get '/projets/:projet_id/invitations/edition/operateur/:operateur_id', to: 'invitations#edit', as: 'edit_invitation'
    get '/invitations/:jeton_id', to: 'invitations#show', as: 'invitation'
  end
  scope(path_names: { new: 'nouvelle' }) do
    resources :sessions, only: [:new, :create]
  end
end 
