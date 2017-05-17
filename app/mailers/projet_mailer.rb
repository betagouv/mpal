class ProjetMailer < ActionMailer::Base
  add_template_helper(ApplicationHelper)
  default delivery_method: Proc.new { Rails.env.production? && !Tools.demo? ? :smtp : :letter_opener_web }
  default from: ENV["NO_REPLY_FROM"]

  def recommandation_operateurs(projet)
    @projet = projet
    @demandeur = projet.demandeur
    @pris = projet.invited_pris
    mail(
      to: projet.email,
      subject: t('mailers.projet_mailer.recommandation_operateurs.sujet')
    )
  end

  # Et si le PRIS change d'avis sur les opérateurs suggérés ?

  def invitation_intervenant(invitation)
    @invitation = invitation
    mail(
      to: invitation.intervenant.email,
      subject: t('mailers.projet_mailer.invitation_intervenant.sujet', demandeur: @invitation.demandeur.fullname)
    )
  end

  def notification_invitation_intervenant(invitation)
    @invitation = invitation
    mail(
      to: invitation.projet.email,
      subject: t('mailers.projet_mailer.notification_invitation_intervenant.sujet', intervenant: @invitation.intervenant.raison_sociale)
    )
  end

  def resiliation_operateur(invitation)
    @invitation = invitation
    mail(
    to: invitation.intervenant.email,
    subject: t('mailers.projet_mailer.resiliation_operateur.sujet', demandeur: @invitation.demandeur.fullname)
    )
  end

  def notification_engagement_operateur(projet)
    @projet = projet
    @invitation = @projet.invitations.find_by_intervenant_id(projet.operateur_id)
    mail(
    to: @projet.operateur.email,
    subject: t('mailers.projet_mailer.notification_engagement_operateur.sujet', intervenant: @projet.operateur.raison_sociale, demandeur: @projet.demandeur.fullname)
    )
  end

  def mise_en_relation_intervenant(invitation)
    @invitation = invitation
    mail(
    to: invitation.intervenant.email,
    subject: t('mailers.projet_mailer.mise_en_relation_intervenant.sujet', intermediaire: @invitation.intermediaire.raison_sociale)
    )
  end

  def accuse_reception(projet)
    @projet = projet
    @demandeur = projet.demandeur
    @instructeur = projet.invited_instructeur
    @date_depot = projet.date_depot
    mail(
      from: projet.invited_instructeur.email,
      to: projet.email,
      subject: t('mailers.projet_mailer.accuse_reception.sujet')
    )
  end
end
