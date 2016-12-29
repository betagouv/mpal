class InfosProjetController < ApplicationController
  skip_before_action :authentifie
  layout "info-projet"

  def faq
  end

  def cgu
  end

  def mentions_legales
  end
end
