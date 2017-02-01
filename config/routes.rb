Rails.application.routes.draw do
  concern :projectable do
    resources :occupants,          only: [:new, :create, :edit, :update, :destroy]
    resources :commentaires,       only: :create
    resource  :composition
    resources :avis_impositions
    resources :prestations,        only: [:create]
    resources :aides,              only: [:create]
    resources :documents,          only: [:create, :destroy]
    resources :intervenants
    resources :choix_intervenants, only: [:new, :create]
    get       :calcul_revenu_fiscal_reference
    get       :preeligibilite
    get       :demande
    get       :suivi
    post      :transfert_csv, to: 'transfert_csv#create'
  end

  devise_for :agents, controllers: { cas_sessions: 'my_cas' }
  root 'sessions#new'
  namespace :api, path: '/api/v1/projets/:projet_id' do
    get  '/', to: 'projets#show', as: 'projet'
    post '/plan_financements', to: 'plans_financements#create', as: 'projet_plan_financements'
  end
  scope(path_names: { new: 'nouveau', edit: 'edition' }) do
    resources :dossiers, only: [], concerns: :projectable do
      post :dossiers_opal, controller: 'dossiers_opal', action: 'create'
      get  :affecter_agent
      get  :proposer
    end
    resources :dossiers, only: [:show, :edit, :update, :index], param: :dossier_id

    resources :projets, only: [], concerns: :projectable do
      resources :transmissions, only: [:create]
      get  :accepter
    end
    resources :projets, only: [:show, :edit, :update], param: :projet_id

    get   '/projets/:projet_id/mes_infos', to: 'demarrage_projet#etape1_recuperation_infos', as: 'etape1_recuperation_infos_demarrage_projet'
    post  '/projets/:projet_id/mes_infos', to: 'demarrage_projet#etape1_envoi_infos'

    get   '/projets/:projet_id/mon_projet', to: 'demarrage_projet#etape2_description_projet', as: 'etape2_description_projet'
    patch '/projets/:projet_id/mon_projet', to: 'demarrage_projet#etape2_envoi_description_projet'

    get   '/projets/:projet_id/choix_operateur', to: 'demarrage_projet#etape3_choix_intervenant', as: 'etape3_choix_intervenant'
    patch '/projets/:projet_id/choix_operateur', to: 'demarrage_projet#etape3_envoi_choix_intervenant'

    get   '/projets/:projet_id/invitations/intervenant/:intervenant_id', to: 'invitations#new', as: 'new_invitation'
    post  '/projets/:projet_id/invitations/intervenant/:intervenant_id', to: 'invitations#create', as: 'invitations'
    get   '/projets/:projet_id/invitations/edition/intervenant/:intervenant_id', to: 'invitations#edit', as: 'edit_invitation'

    get '/reset' => 'tools#reset_base'

    get '/instruction', to: 'instruction#show', as: 'instruction'
  end
  scope(path_names: { new: 'nouvelle' }) do
    resources :sessions, only: [:new, :create]
  end

  get  '/deconnexion', to: 'sessions#deconnexion'
  resources :dossiers, only: []
  get  '/informations/faq', to: 'informations#faq'
  get  '/informations/cgu', to: 'informations#cgu'
  get  '/informations/mentions_legales', to: 'informations#mentions_legales'

  require "sidekiq/web"
  Sidekiq::Web.use Rack::Auth::Basic do |username, password|
    username == ENV["SIDEKIQ_USERNAME"] && password == ENV["SIDEKIQ_PASSWORD"]
  end if Rails.env.production?
  mount Sidekiq::Web, at: "/sidekiq"

  mount LetterOpenerWeb::Engine, at: "/letter_opener"
end
