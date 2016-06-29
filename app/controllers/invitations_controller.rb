class InvitationsController < ApplicationController
  def new
    @projet = @projet_courant
    @intervenant = Intervenant.find(params[:intervenant_id])
  end

  def create
    if @utilisateur_courant.is_a? Intervenant
      create_mise_en_relation
    else
      create_invitation
    end
  end

  def create_mise_en_relation
    @projet = @projet_courant
    @intervenant = Intervenant.find(params[:intervenant_id])
    @invitation = Invitation.new(projet: @projet, intermediaire: @utilisateur_courant, intervenant: @intervenant)
    if @invitation.save
      ProjetMailer.mise_en_relation_intervenant(@invitation).deliver_later!
      EvenementEnregistreurJob.perform_later(label: 'mise_en_relation_intervenant', projet: @projet_courant, producteur: @invitation)
      redirect_to projet_path(@projet, jeton: params[:jeton]), notice: t('invitations.messages.succes', intervenant: @intervenant.raison_sociale)
    else
      raise "error: #{@invitation.errors.full_messages}"
    end
  end

  def create_invitation
    @projet = @projet_courant
    @intervenant = Intervenant.find(params[:intervenant_id])
    @projet.adresse = params[:projet][:adresse]
    @projet.description = params[:projet][:description]
    @projet.email = params[:projet][:email]
    @projet.tel = params[:projet][:tel]
    @invitation = Invitation.new(projet: @projet, intervenant: @intervenant)
    if valid? && @projet.save && @invitation.save
      ProjetMailer.invitation_intervenant(@invitation).deliver_later!
      EvenementEnregistreurJob.perform_later(label: 'invitation_intervenant', projet: @projet, producteur: @invitation)
      flash[:notice_titre] = t('invitations.messages.succes_titre')
      redirect_to projet_path(@projet, jeton: params[:jeton]), notice: t('invitations.messages.succes', intervenant: @intervenant.raison_sociale)
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
