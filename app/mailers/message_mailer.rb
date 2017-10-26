class MessageMailer < ApplicationMailer
  def messagerie_instantanee(projet)
    @projet = projet
    @demandeur = projet.demandeur
    mail(
      to: projet.email,
      cc: projet.personne.try(:email),
      subject: t('mailers.messagerie_mailer.nouveau_message.sujet')
    )
  end
end