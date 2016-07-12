Rails.application.routes.draw do
  root 'welcome#index'
  constraints subdomain: "api.#{ENV['SUBDOMAIN']}", format: 'json' do
    namespace :api, path: '/v1/' do
      resources :projets, only: :show
    end
  end
  scope(path_names: { new: 'nouveau', edit: 'edition' }) do
    resources :projets, only: [:show, :edit, :update] do
      get '/calcul_revenu_fiscal_reference', to: 'projets#calcul_revenu_fiscal_reference', as: 'calcul_revenu_fiscal_reference'
      resources :occupants, only: [:new, :create, :edit, :update] do
        resources :avis_impositions
      end
      resources :commentaires, only: :create
      resource  :composition
    end

    get '/projets/:projet_id/invitations/intervenant/:intervenant_id', to: 'invitations#new', as: 'new_invitation'
    post '/projets/:projet_id/invitations/intervenant/:intervenant_id', to: 'invitations#create', as: 'invitations'
    get '/projets/:projet_id/invitations/edition/intervenant/:intervenant_id', to: 'invitations#edit', as: 'edit_invitation'

    get '/reset' => 'tools#reset_base'

  end
  scope(path_names: { new: 'nouvelle' }) do
    resources :sessions, only: [:new, :create]
  end

  require "sidekiq/web"
  Sidekiq::Web.use Rack::Auth::Basic do |username, password|
    username == ENV["SIDEKIQ_USERNAME"] && password == ENV["SIDEKIQ_PASSWORD"]
  end if Rails.env.production?
  mount Sidekiq::Web, at: "/sidekiq"
end
