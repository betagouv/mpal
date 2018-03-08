Rails.application.routes.draw do

  #COMMUN ENTRE DOSSIER ET PROJETS
  concern :projectable do
    resources :occupants, only: [:index, :new, :create, :edit, :update, :destroy] do
      post :index, on: :collection
    end
    resource  :composition
    resources :avis_impositions,   only: [:index, :new, :create, :destroy]
    resources :documents,          only: [:create, :destroy, :index]
    resources :intervenants,       only: [:index]
    resource  :demandeur,          only: [:show, :update]
    resource  :demande,            only: [:show, :update]
    resources :messages,           only: [:new, :create]
    resource  :mise_en_relation,   only: [:show, :update]
    resource  :eligibility,        only: :show
    get       :calcul_revenu_fiscal_reference
    get       :preeligibilite
    post       :show_non_eligible, to: "demandes#show_non_eligible"
    get       :show_non_eligible, to: "demandes#show_non_eligible"
    post       :show_a_reevaluer, to: "demandes#show_a_reevaluer"
    get       :show_eligible_hma, to: "mises_en_relation#show_eligible_hma"
    post       :show_eligible_hma_valid_operateur, to: "mises_en_relation#show_eligible_hma_valid_operateur"
  end


  #ROOT & PAGES STATIQUES
  root "homepage#index"

  get "/maintenance",                to: "application#maintenance"

  get  "/informations/about",        to: "informations#about"
  get  "/informations/faq",          to: "informations#faq"
  get  "/informations/terms_of_use", to: "informations#terms_of_use"
  get  "/informations/legal",        to: "informations#legal"
  get  "/stats",                     to: "informations#stats"
  get  "/robots.:format",            to: "informations#robots"

  get  "/patterns",                  to: "patterns#index"
  get  "/patterns/forms",            to: "patterns#forms"
  get  "/patterns/icons",            to: "patterns#icons"
  get  "/patterns/components",       to: "patterns#components"

  get  "/debug_exception",           to: "application#debug_exception"



  #CONTACTS
  resources :contacts, only: [:index, :new, :create]

  #DEVISE & SESSIONS
  devise_for :users, controllers: {
    passwords:     "users/passwords",
    registrations: "users/registrations",
    sessions:      "users/sessions",
    confirmations: 'users/confirmations'
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
      get  :list_department_intervenants
      patch :update_project_intervenants
      get  :recommander_operateurs
      post :recommander_operateurs
      get  :manage_eligibility
      post :confirm_eligibility
      get  :proposer
      get  :proposition
      put  :proposition
      get  :indicateurs, on: :collection
      get :desactivate, controller: "dossiers", action: "desactivate", on: :collection
      get :activate, controller: "dossiers", action: "activate", on: :collection
      resources :payments, only: [:index, :new, :create, :edit, :update, :destroy, :ask_for_validation, :ask_for_modification, :send_in_opal], param: :payment_id do
        put "ask_for_validation",   on: :member
        put "ask_for_modification", on: :member
        put "send_in_opal",         on: :member
      end
      resources :payments, only: [] do
        resources :documents, only: [:create, :destroy]
      end
    end
    resources :dossiers, only: [:show, :edit, :update, :index], param: :dossier_id

    #PROJETS
    get  "/projets/new", to: "projets#new"
    post  "/projets/",   to: "projets#create"
    resources :projets, only: [:show, :edit, :update, :index], param: :projet_id

    resources :projets, only: [], concerns: :projectable do
      resource :users, only: [:new, :create]
      get      "demandeur/departement_non_eligible", action: :departement_non_eligible, controller: "demandeurs"
      get      :choix_operateur,      action: :new,    controller: "choix_operateur"
      patch    :choix_operateur,      action: :choose, controller: "choix_operateur"
      get      :engagement_operateur, action: :new,    controller: "engagement_operateur"
      post     :engagement_operateur, action: :create, controller: "engagement_operateur"
      get      "invitations/:role",   action: :show,   controller: "invitations"
      get      :transmission,         action: :new,    controller: "transmission"
      post     :transmission,         action: :create, controller: "transmission"
      resources :payments, only: [:index, :ask_for_modification, :ask_for_instruction], param: :payment_id do
        put "ask_for_modification", on: :member
        put "ask_for_instruction",  on: :member
      end
    end

    get "/reset" => "tools#reset_base"

    get "/instruction", to: "instruction#show", as: "instruction"
  end


  # mise a jours des dossiers avec la position OPAL; Opal contact l'api regulierement
  put '/api/update_state/dossiers/batch' => "apis#update_state"
  put '/api/update_state/aides/batch' => "apis#not_implemented"
  put '/api/update_state/paiements/batch' => "apis#not_implemented"
  put "/api/update_statenet/sio/json/aides/batch" => "apis#not_implemented"
  put "/api/update_statenet/sio/json/dossiers/batch" => "apis#not_implemented"
  put "/api/update_statenet/sio/json/paiements/batch" => "apis#not_implemented"

  # gestion des fonctions administrateurs
  get '/api/particulier/refresh/:project_id' => "dossiers#update_api_particulier"
  get "/ruby_rod/:id" => "dossiers#ruby_rod"


  require "sidekiq/web"
  Sidekiq::Web.use Rack::Auth::Basic do |username, password|
    username == ENV["SIDEKIQ_USERNAME"] && password == ENV["SIDEKIQ_PASSWORD"]
  end if Rails.env.production?
  mount Sidekiq::Web, at: "/sidekiq"

  mount LetterOpenerWeb::Engine, at: "/letter_opener"
  match '/*path', :to => 'application#error_not_found', :via => :all
end

