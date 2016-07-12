class ProjetMailer < ActionMailer::Base
  default :from => ENV["NO_REPLY_FROM"]

  def invitation_intervenant(invitation)
    @invitation = invitation
    mail(to: invitation.intervenant_email, subject: t('mailers.projet_mailer.invitation_intervenant.sujet', usager: @invitation.usager))
  end

  def notification_invitation_intervenant(invitation)
    @invitation = invitation
    mail(to: invitation.projet_email, subject: t('mailers.projet_mailer.notification_invitation_intervenant.sujet', intervenant: @invitation.intervenant.to_s))
  end


  def mise_en_relation_intervenant(invitation)
    @invitation = invitation
    mail(to: invitation.intervenant_email, subject: t('mailers.projet_mailer.mise_en_relation_intervenant.sujet', intermediaire: @invitation.intermediaire))
  end
end
