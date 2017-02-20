class InformationsController < ApplicationController
  layout 'informations'

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
