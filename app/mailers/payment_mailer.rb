class PaymentMailer < ActionMailer::Base
  add_template_helper(ApplicationHelper)
  default delivery_method: Proc.new { Rails.env.production? && !Tools.demo? ? :smtp : :letter_opener_web }
  default from: ENV["EMAIL_CONTACT"]

  def notification_validation_dossier_paiement(payment)
    @payment = payment
    @projet = @payment.payment_registry.projet
    mail(
      to: @projet.email,
      cc: @projet.personne.try(:email),
      subject: t('mailers.dossier_paiement_mailer.notification_validation_dossier_paiement.sujet')
    )
  end

  def depot_dossier_paiement(payment)
    @payment = payment
    @projet = @payment.payment_registry.projet
    mail(
      to: @projet.invited_instructeur.email,
      cc: @projet.operateur.email,
      subject: t('mailers.dossier_paiement_mailer.depot_dossier_paiement.sujet', demandeur: @projet.demandeur.fullname)
    )
    end

  def accuse_reception_dossier_paiement(payment)
    @payment = payment
    @projet = @payment.payment_registry.projet
    mail(
        to: @projet.email,
        cc: @projet.personne.try(:email),
        subject: t('mailers.dossier_paiement_mailer.accuse_reception.sujet')
    )
  end

  def demande_modification(payment)
    @payment = payment
    @projet = @payment.payment_registry.projet
    mail(
        to: @projet.operateur.email,
        subject: t('mailers.dossier_paiement_mailer.demande_modification.sujet', demandeur: @projet.demandeur.fullname)
    )
  end

#    VERIFIER AVEC CELINE L'UTILITE DE FAIRE CA
#   def suppression_dossier_paiement(payment)
#     @payment = payment
#     @projet = payment.payment_registry.projet
#     @demandeur = @projet.demandeur
#
#     mail(
#         to: @projet.email,
#         cc: @projet.personne.try(:email),
#         subject: t('mailers.dossier_paiement_mailer.suppression_dossier_paiement.sujet')
#     )
#   end


end
