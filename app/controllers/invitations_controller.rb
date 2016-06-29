class InvitationsController < ApplicationController
  def new
    @projet = @projet_courant
    @intervenant = Intervenant.find(params[:intervenant_id])
  end

  def create
    @projet = @projet_courant
    @intervenant = Intervenant.find(params[:intervenant_id])
    @projet.adresse = params[:projet][:adresse]
    @projet.description = params[:projet][:description]
    @projet.email = params[:projet][:email]
    @projet.tel = params[:projet][:tel]
    @invitation = Invitation.new(projet: @projet, intervenant: @intervenant)
    if valid? && @projet.save && @invitation.save
      ProjetMailer.invitation_intervenant(@invitation).deliver_now!
      flash[:notice_titre] = t('invitations.messages.succes_titre')
      redirect_to @projet, notice: t('invitations.messages.succes', intervenant: @intervenant.raison_sociale)
    else
      render :new
    end
  end


  private
  def valid?
    @projet.errors[:adresse] = t('invitations.messages.adresse.obligatoire') unless @projet.adresse.present?
    @projet.errors[:description] = t('invitations.messages.description.obligatoire') unless @projet.description.present?
    @projet.errors[:email] = t('invitations.messages.email.obligatoire') unless @projet.email.present?
    @projet.description.present? && @projet.email.present? && @projet.adresse.present?
  end
end
