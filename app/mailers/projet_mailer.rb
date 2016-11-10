class ProjetMailer < ActionMailer::Base
  default :from => ENV["NO_REPLY_FROM"]

  def invitation_intervenant(invitation)
    @invitation = invitation
    mail(to: invitation.intervenant_email, subject: t('mailers.projet_mailer.invitation_intervenant.sujet', demandeur_principal: @invitation.demandeur_principal))
  end

  def notification_invitation_intervenant(invitation)
    @invitation = invitation
    mail(to: invitation.projet_email, subject: t('mailers.projet_mailer.notification_invitation_intervenant.sujet', intervenant: @invitation.intervenant.to_s))
    # pourquoi intervenant.to_s et pas intermediaie.to_s ?
  end

  def notification_choix_intervenant(projet)
    @projet = projet
    mail(to: @projet.operateur.email, subject: t('mailers.projet_mailer.notification_choix_intervenant.sujet', intervenant: @projet.operateur, demandeur_principal: @projet.demandeur_principal))
  end

  def mise_en_relation_intervenant(invitation)
    @invitation = invitation
    mail(to: invitation.intervenant_email, subject: t('mailers.projet_mailer.mise_en_relation_intervenant.sujet', intermediaire: @invitation.intermediaire))
  end
end
