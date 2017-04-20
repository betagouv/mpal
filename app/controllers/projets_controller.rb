class ProjetsController < ApplicationController
  include ProjetConcern

  before_action :projet_or_dossier
  before_action :assert_projet_courant
  before_action :authentifie
end
