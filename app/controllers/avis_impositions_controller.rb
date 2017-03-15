class AvisImpositionsController < ApplicationController
  layout 'inscription'

  before_action :dossier_ou_projet
  before_action :assert_projet_courant
  before_action :authentifie
  before_action :init_view

  def index
  end

private
  def init_view
    @page_heading = 'Inscription'
  end
end

