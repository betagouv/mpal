class InfosProjetController < ActionController::Base

  def faq
    render :layout => 'application'
  end

  def cgu
    render :layout => 'application'
  end

  def mentions_legales
    render :layout => 'application'
  end
end
