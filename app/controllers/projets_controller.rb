class ProjetsController < ApplicationController
  def show
    @projet = Projet.find(params[:id])
    if session[:numero_fiscal] != @projet.numero_fiscal
      redirect_to new_session_path, alert: t('sessions.access_forbidden')
    else
      gon.push({
        latitude: @projet.latitude,
        longitude: @projet.longitude
      })
      @contact = @projet.contacts.build
      @contact.role = 'syndic'
    end
  end
end
