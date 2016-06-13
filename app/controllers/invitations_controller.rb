class InvitationsController < ApplicationController
  def new
    @projet = Projet.find(params[:projet_id])
    @operateur = Operateur.find(params[:operateur_id])
  end

  def create
    @projet = Projet.find(params[:projet_id])
    @operateur = Operateur.find(params[:operateur_id])
    @projet.adresse = params[:projet][:adresse]
    @projet.description = params[:projet][:description]
    @projet.email = params[:projet][:email]
    @projet.tel = params[:projet][:tel]
    if valid? && @projet.save
      redirect_to @projet, notice: t('invitations.messages.succes', operateur: @operateur.raison_sociale)
    else
      render :new
    end
  end

  private
  def valid?
    @projet.errors[:adresse] = t('invitations.attributs.adresse.obligatoire') unless @projet.adresse.present?
    @projet.errors[:description] = t('invitations.attributs.description.obligatoire') unless @projet.description.present?
    @projet.errors[:email] = t('invitations.attributs.email.obligatoire') unless @projet.email.present?
    @projet.description.present? && @projet.email.present? && @projet.adresse.present?
  end
end
