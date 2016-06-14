class ProjetMailer < ActionMailer::Base
  default :from => ENV["NO_REPLY_FROM"]

  def invitation_operateur(invitation)
    @invitation = invitation
    mail(to: invitation.operateur_email, subject: t('mailers.projet_mailer.invitation_operateur.sujet', usager: @invitation.usager))
  end
end
