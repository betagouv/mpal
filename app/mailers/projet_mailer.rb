class ProjetMailer < ActionMailer::Base
  default :from => ENV["NO_REPLY_FROM"]

  def invitation_operateur(projet, operateur)
    @projet = projet
    mail(to: operateur.email, subject: t('mailers.projet_mailer.invitation_operateur.sujet', usager: @projet.usager))
  end
end
