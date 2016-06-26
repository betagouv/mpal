class IntervenantProjetsController < ApplicationController
  protect_from_forgery with: :exception
  skip_before_action :authenticate

  def show
    invitation = Invitation.find_by_token(params[:id])
    @projet = invitation.projet
    gon.push({
      latitude: @projet.latitude,
      longitude: @projet.longitude
    })
    @profil = invitation.intervenant.raison_sociale
    @intervenants_disponibles = @projet.intervenants_disponibles(role: :operateur)
  end
end
