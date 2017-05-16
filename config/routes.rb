Rails.application.routes.draw do
  concern :projectable do
    resources :occupants, only: [:index, :new, :create, :edit, :update, :destroy] do
      post :index, on: :collection
    end
    resources :commentaires,       only: :create
    resource  :composition
    resources :avis_impositions,   only: [:index, :new, :create, :destroy]
    resources :documents,          only: [:create, :destroy]
    resources :intervenants
    resource :demandeur,         only: [:show, :update]
    resource :demande,           only: [:show, :update]
    resource :mise_en_relation,  only: [:show, :update]
    get       :calcul_revenu_fiscal_reference
    get       :preeligibilite
  end

  devise_for :agents, controllers: { cas_sessions: 'my_cas' }
  devise_scope :agent do
    get '/agents/signed_out', to: 'my_cas#signed_out'
  end

  root 'sessions#new'
  namespace :api, path: '/api/v1/projets/:projet_id' do
    get  '/', to: 'projets#show', as: 'projet'
    post '/plan_financements', to: 'plans_financements#create', as: 'projet_plan_financements'
  end

  scope(path_names: { new: 'nouveau', edit: 'edition' }) do
    resources :dossiers, only: [], concerns: :projectable do
      post :dossiers_opal, controller: 'dossiers_opal', action: 'create'
      get  :affecter_agent
      get  :recommander_operateurs
      post :recommander_operateurs
      get  :proposer
      get  :proposition
      put  :proposition
      get  :indicateurs, on: :collection
    end
    resources :dossiers, only: [:show, :edit, :update, :index], param: :dossier_id

    resources :projets, only: [], concerns: :projectable do
      get      :choix_operateur,      action: :new,    controller: 'choix_operateur'
      patch    :choix_operateur,      action: :choose, controller: 'choix_operateur'
      get      :engagement_operateur, action: :new,    controller: 'engagement_operateur'
      post     :engagement_operateur, action: :create, controller: 'engagement_operateur'
      get      :transmission,         action: :new,    controller: 'transmission'
      post     :transmission,         action: :create, controller: 'transmission'
    end

    resources :projets, only: [:show, :edit, :update], param: :projet_id



    get   '/projets/:projet_id/invitations/intervenant/:intervenant_id', to: 'invitations#new', as: 'new_invitation'
    post  '/projets/:projet_id/invitations/intervenant/:intervenant_id', to: 'invitations#create', as: 'invitations'
    get   '/projets/:projet_id/invitations/edition/intervenant/:intervenant_id', to: 'invitations#edit', as: 'edit_invitation'

    get '/reset' => 'tools#reset_base'

    get '/instruction', to: 'instruction#show', as: 'instruction'
  end
  scope(path_names: { new: 'nouvelle' }) do
    resources :sessions, only: [:new, :create]
  end

  namespace :admin do
    root to: 'home#index'
    resources :themes
    resources :intervenants do
      post 'import', on: :collection
    end
  end

  get  '/deconnexion', to: 'sessions#deconnexion'
  resources :dossiers, only: []

  get  '/informations/about',        to: 'informations#about'
  get  '/informations/faq',          to: 'informations#faq'
  get  '/informations/terms_of_use', to: 'informations#terms_of_use'
  get  '/informations/legal',        to: 'informations#legal'

  get  '/patterns',                  to: 'patterns#index'
  get  '/patterns/forms',            to: 'patterns#forms'

  resources :contacts, only: [:index, :new, :create]

  require "sidekiq/web"
  Sidekiq::Web.use Rack::Auth::Basic do |username, password|
    username == ENV["SIDEKIQ_USERNAME"] && password == ENV["SIDEKIQ_PASSWORD"]
  end if Rails.env.production?
  mount Sidekiq::Web, at: "/sidekiq"

  mount LetterOpenerWeb::Engine, at: "/letter_opener"
end
