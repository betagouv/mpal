class MessageMailer < ApplicationMailer
  def messagerie_instantanee(projet, message)
    @projet = projet
    @demandeur = projet.demandeur
    @message = message
    mail(
      to: projet.email,
      cc: projet.personne.try(:email),
      subject: t('mailers.messagerie_mailer.nouveau_message.sujet')
    )
  end
end