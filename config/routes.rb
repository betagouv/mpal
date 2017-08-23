Rails.application.routes.draw do

  #COMMUN ENTRE DOSSIER ET PROJETS
  concern :projectable do
    resources :occupants, only: [:index, :new, :create, :edit, :update, :destroy] do
      post :index, on: :collection
    end
    resource  :composition
    resources :avis_impositions,   only: [:index, :new, :create, :destroy]
    resources :documents,          only: [:create, :destroy, :index]
    resources :intervenants
    resource  :demandeur,          only: [:show, :update]
    resource  :demande,            only: [:show, :update]
    resources :messages,           only: [:new, :create]
    resource  :mise_en_relation,   only: [:show, :update]
    resource  :eligibility,        only: :show
    get       :calcul_revenu_fiscal_reference
    get       :preeligibilite
    get       "/payment_registry", to: "payment_registries#show"
  end

  #ROOT & PAGES STATIQUES
  root "homepage#index"

  get  "/informations/about",        to: "informations#about"
  get  "/informations/faq",          to: "informations#faq"
  get  "/informations/terms_of_use", to: "informations#terms_of_use"
  get  "/informations/legal",        to: "informations#legal"
  get  "/stats",                     to: "informations#stats"

  get  "/patterns",                  to: "patterns#index"
  get  "/patterns/forms",            to: "patterns#forms"
  get  "/patterns/icons",            to: "patterns#icons"
  get  "/patterns/components",       to: "patterns#components"

  get  "/debug_exception",           to: "application#debug_exception"

  match "/404", via: :all, to: "errors#not_found"
  match "/500", via: :all, to: "errors#internal_server_error"

  #CONTACTS
  resources :contacts, only: [:index, :new, :create]

  #DEVISE & SESSIONS
  devise_for :users, controllers: {
    passwords:     "users/passwords",
    registrations: "users/registrations",
    sessions:      "users/sessions",
  }
  devise_for :agents, controllers: { cas_sessions: "my_cas" }
  devise_scope :agent do
    get "/agents/signed_out", to: "my_cas#signed_out"
  end
  get  "/deconnexion", to: "sessions#deconnexion"


  #ROUTES PRINCIPALES DOSSIERS ET PROJETS
  scope(path_names: { new: "nouveau", edit: "edition" }) do

    #DOSSIERS
    resources :dossiers, only: [], concerns: :projectable do
      get  :home, on: :collection
      post :dossiers_opal, controller: "dossiers_opal", action: "create"
      put  :update_project_rfr, controller: "avis_impositions", action: "update_project_rfr"
      get  :affecter_agent
      get  :recommander_operateurs
      post :recommander_operateurs
      get  :proposer
      get  :proposition
      put  :proposition
      get  :indicateurs, on: :collection
      post "/payment_registry", to: "payment_registries#create"
      resources :payments, only: [:new, :create, :edit, :update, :destroy, :ask_for_validation, :ask_for_modification, :send_in_opal], param: :payment_id do
        put "ask_for_validation",   on: :member
        put "ask_for_modification", on: :member
        put "send_in_opal", on: :member
      end
    end
    resources :dossiers, only: [:show, :edit, :update, :index], param: :dossier_id

    #PROJETS
    get  "/projets/new", to: "projets#new"
    post  "/projets/",   to: "projets#create"
    resources :projets, only: [:show, :edit, :update], param: :projet_id

    resources :projets, only: [], concerns: :projectable do
      resource :users, only: [:new, :create]
      get      "demandeur/departement_non_eligible", action: :departement_non_eligible, controller: "demandeurs"
      get      :choix_operateur,      action: :new,    controller: "choix_operateur"
      patch    :choix_operateur,      action: :choose, controller: "choix_operateur"
      get      :engagement_operateur, action: :new,    controller: "engagement_operateur"
      post     :engagement_operateur, action: :create, controller: "engagement_operateur"
      get      :transmission,         action: :new,    controller: "transmission"
      post     :transmission,         action: :create, controller: "transmission"
      resources :payments, only: [:ask_for_modification, :ask_for_instruction], param: :payment_id do
        put "ask_for_modification", on: :member
        put "ask_for_instruction",  on: :member
      end
    end

    get   "/projets/:projet_id/invitations/intervenant/:intervenant_id", to: "invitations#new", as: "new_invitation"
    post  "/projets/:projet_id/invitations/intervenant/:intervenant_id", to: "invitations#create", as: "invitations"
    get   "/projets/:projet_id/invitations/edition/intervenant/:intervenant_id", to: "invitations#edit", as: "edit_invitation"

    get "/reset" => "tools#reset_base"

    get "/instruction", to: "instruction#show", as: "instruction"
  end

  #PAGES ADMIN
  namespace :admin do
    root to: "home#index"
    resources :themes
    resources :intervenants
  end

  require "sidekiq/web"
  Sidekiq::Web.use Rack::Auth::Basic do |username, password|
    username == ENV["SIDEKIQ_USERNAME"] && password == ENV["SIDEKIQ_PASSWORD"]
  end if Rails.env.production?
  mount Sidekiq::Web, at: "/sidekiq"

  mount LetterOpenerWeb::Engine, at: "/letter_opener"
end

