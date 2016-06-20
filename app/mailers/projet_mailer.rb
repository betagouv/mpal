class ProjetMailer < ActionMailer::Base
  default :from => ENV["NO_REPLY_FROM"]

  def invitation_intervenant(invitation)
    @invitation = invitation
    mail(to: invitation.intervenant_email, subject: t('mailers.projet_mailer.invitation_intervenant.sujet', usager: @invitation.usager))
  end
end
