Rails.application.routes.draw do
  devise_for :agents, controllers: { cas_sessions: 'my_cas' }
  root 'welcome#index'
  namespace :api, path: '/api/v1/' do
    resources :projets, only: :show do
      resource :plan_financements, only: :create
    end
  end
  scope(path_names: { new: 'nouveau', edit: 'edition' }) do
    resources :projets, only: [:show, :edit, :update, :index] do
      resources :occupants, only: [:new, :create, :edit, :update, :destroy]
      resources :commentaires, only: :create
      resource  :composition
      resources :avis_impositions
      resources :prestations, only: [:create]
      resources :aides, only: [:create]
      resources :documents, only: [:create, :destroy]
      resources :intervenants
      resources :choix_intervenants, only: [:new, :create]
      resources :transmissions, only: [:create]
      resources :dossiers, only: [:create]

      get '/calcul_revenu_fiscal_reference', to: 'projets#calcul_revenu_fiscal_reference', as: 'calcul_revenu_fiscal_reference'
      get '/preeligibilite', to: 'projets#preeligibilite', as: 'preeligibilite'
      get '/demande', to: 'projets#demande', as: 'demande'
      get '/suivi', to: 'projets#suivi', as: 'suivi'

      post '/transfert_csv', to: 'transfert_csv#create'
    end

    get '/projets/:projet_id/invitations/intervenant/:intervenant_id', to: 'invitations#new', as: 'new_invitation'
    post '/projets/:projet_id/invitations/intervenant/:intervenant_id', to: 'invitations#create', as: 'invitations'
    get '/projets/:projet_id/invitations/edition/intervenant/:intervenant_id', to: 'invitations#edit', as: 'edit_invitation'

    get '/reset' => 'tools#reset_base'

    get '/invitations/:jeton_id', to: 'invitations#show', as: 'invitation'
    get '/instruction', to: 'instruction#show', as: 'instruction'
  end
  scope(path_names: { new: 'nouvelle' }) do
    resources :sessions, only: [:new, :create]
  end

  get '/deconnexion', to: 'sessions#deconnexion', as: 'deconnexion'
  get  '/infos_projet/faq', to: 'infos_projet#faq'

  require "sidekiq/web"
  Sidekiq::Web.use Rack::Auth::Basic do |username, password|
    username == ENV["SIDEKIQ_USERNAME"] && password == ENV["SIDEKIQ_PASSWORD"]
  end if Rails.env.production?
  mount Sidekiq::Web, at: "/sidekiq"

  mount LetterOpenerWeb::Engine, at: "/letter_opener"
end
