class InformationsController < ApplicationController
  layout 'informations'

  skip_before_action :dossier_ou_projet
  skip_before_action :assert_projet_courant
  skip_before_action :authentifie

  def faq
    @page_heading = "FAQ"
  end

  def cgu
    @page_heading = "Conditions générales d’utilisation"
  end

  def mentions_legales
    @page_heading = "Mentions légales"
  end
end
