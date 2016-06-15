Rails.application.routes.draw do
  devise_for :agents
  root 'welcome#index'
  scope(path_names: { new: 'nouveau', edit: 'edition' }) do
    resources :projets, only: [:show, :edit, :update]

    get '/projets/:projet_id/invitations/operateur/:operateur_id', to: 'invitations#new', as: 'new_invitation'
    post '/projets/:projet_id/invitations/operateur/:operateur_id', to: 'invitations#create'
    get '/invitations/:jeton_id', to: 'invitations#show', as: 'invitation'
    get '/instruction', to: 'instruction#show', as: 'instruction'
  end
  scope(path_names: { new: 'nouvelle' }) do
    resources :sessions, only: [:new, :create]
  end
end 
