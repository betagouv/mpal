class InfosProjetController < ApplicationController
  layout 'application'

  skip_before_action :dossier_ou_projet
  skip_before_action :assert_projet_courant
  skip_before_action :authentifie

  def faq
  end

  def cgu
  end

  def mentions_legales
  end
end
