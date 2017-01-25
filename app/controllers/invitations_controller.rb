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
      redirect_to projet_path(@projet_courant), notice: t('invitations.messages.succes', intervenant: @intervenant.raison_sociale)
    else
      raise "error: #{@invitation.errors.full_messages}"
    end
  end

  def cree_invitation
    @intervenant = Intervenant.find(params[:intervenant_id])
    service_adresse = ApiBan.new
    adresse = service_adresse.precise(params[:projet][:adresse])
    @projet_courant.longitude = adresse[:longitude]
    @projet_courant.latitude = adresse[:latitude]
    @projet_courant.departement = adresse[:departement]
    @projet_courant.adresse_ligne1 = adresse[:adresse_ligne1]
    @projet_courant.code_insee = adresse[:code_insee]
    @projet_courant.code_postal = adresse[:code_postal]
    @projet_courant.ville = adresse[:ville]

    @projet_courant.description = params[:projet][:description]
    @projet_courant.email = params[:projet][:email]
    @projet_courant.tel = params[:projet][:tel]
    @invitation = Invitation.new(projet: @projet_courant, intervenant: @intervenant)
    if valid? && @projet_courant.save && @invitation.save
      ProjetMailer.invitation_intervenant(@invitation).deliver_later!
      ProjetMailer.notification_invitation_intervenant(@invitation).deliver_later!
      EvenementEnregistreurJob.perform_later(label: 'invitation_intervenant', projet: @projet_courant, producteur: @invitation)
      flash[:notice_titre] = t('invitations.messages.succes_titre')
      redirect_to projet_path(@projet_courant), notice: t('invitations.messages.succes', intervenant: @intervenant.raison_sociale)
    else
      render :new
    end
  end

  private

  def valid?
    @projet_courant.errors[:adresse] = t('invitations.messages.adresse.obligatoire') unless @projet_courant.adresse.present?
    @projet_courant.errors[:description] = t('invitations.messages.description.obligatoire') unless @projet_courant.description.present?
    @projet_courant.errors[:tel] = t('invitations.messages.telephone.obligatoire') unless @projet_courant.tel.present?
    @projet_courant.errors[:email] = t('invitations.messages.email.obligatoire') unless @projet_courant.email.present?
    @projet_courant.errors[:email] = t('projets.edition_projet.messages.erreur_email_invalide') unless email_valide?(@projet_courant.email)
    @projet_courant.description.present? && @projet_courant.email.present? && @projet_courant.adresse.present? && email_valide?(@projet_courant.email) && @projet_courant.tel.present?
  end
end
