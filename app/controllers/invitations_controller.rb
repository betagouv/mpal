class InvitationsController < ApplicationController
  def new
    @projet = Projet.find(params[:projet_id])
    @operateur = Operateur.find(params[:operateur_id])
  end

  def create
    @projet = Projet.find(params[:projet_id])
    @operateur = Operateur.find(params[:operateur_id])
    @projet.themes = params[:projet][:themes]
    @projet.description = params[:projet][:description]
    @projet.email = params[:projet][:email]
    @projet.tel = params[:projet][:tel]
    if @projet.save
      redirect_to @projet, notice: t('invitations.messages.succes', operateur: @operateur.raison_sociale)
    end
  end
end
