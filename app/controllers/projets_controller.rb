class ProjetsController < ApplicationController
  include ProjetConcern

  before_action :dossier_ou_projet
  before_action :assert_projet_courant
  before_action :authentifie
end
