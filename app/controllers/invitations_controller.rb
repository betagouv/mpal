class InvitationsController < ApplicationController

  def new
    @intervenant = Intervenant.find(params[:intervenant_id])
  end

  def create
    if @utilisateur_courant.is_a? Intervenant
      cree_mise_en_relation
    else
      cree_invitation
    end
  end

  def cree_mise_en_relation
    @intervenant = Intervenant.find(params[:intervenant_id])
    @invitation = @projet_courant.invitations.where(intervenant: @intervenant).first
    if @invitation
      @invitation.intermediaire = @utilisateur_courant
    else
      @invitation = Invitation.new(projet: @projet_courant, intermediaire: @utilisateur_courant, intervenant: @intervenant)
    end
    if @invitation.save
      ProjetMailer.mise_en_relation_intervenant(@invitation).deliver_later!
      EvenementEnregistreurJob.perform_later(label: 'mise_en_relation_intervenant', projet: @projet_courant, producteur: @invitation)
      redirect_to projet_path(@projet_courant, jeton: params[:jeton]), notice: t('invitations.messages.succes', intervenant: @intervenant.raison_sociale)
    else
      raise "error: #{@invitation.errors.full_messages}"
    end
  end

  def cree_invitation
    @intervenant = Intervenant.find(params[:intervenant_id])
    @projet_courant.adresse = params[:projet][:adresse]
    @projet_courant.description = params[:projet][:description]
    @projet_courant.email = params[:projet][:email]
    @projet_courant.tel = params[:projet][:tel]
    @invitation = Invitation.new(projet: @projet_courant, intervenant: @intervenant)
    if valid? && @projet_courant.save && @invitation.save
      ProjetMailer.invitation_intervenant(@invitation).deliver_later!
      ProjetMailer.notification_invitation_intervenant(@invitation).deliver_later!
      EvenementEnregistreurJob.perform_later(label: 'invitation_intervenant', projet: @projet_courant, producteur: @invitation)
      flash[:notice_titre] = t('invitations.messages.succes_titre')
      redirect_to projet_path(@projet_courant, jeton: params[:jeton]), notice: t('invitations.messages.succes', intervenant: @intervenant.raison_sociale)
    else
      render :new
    end
  end

  private

  def valid?
    @projet_courant.errors[:adresse] = t('invitations.messages.adresse.obligatoire') unless @projet_courant.adresse.present?
    @projet_courant.errors[:description] = t('invitations.messages.description.obligatoire') unless @projet_courant.description.present?
    @projet_courant.errors[:email] = t('invitations.messages.email.obligatoire') unless @projet_courant.email.present?
    @projet_courant.description.present? && @projet_courant.email.present? && @projet_courant.adresse.present?
  end
end
