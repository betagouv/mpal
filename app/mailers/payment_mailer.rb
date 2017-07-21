class PaymentMailer < ActionMailer::Base
  default delivery_method: Proc.new { Rails.env.production? && !Tools.demo? ? :smtp : :letter_opener_web }
  default from: ENV["EMAIL_CONTACT"]

  def notification_validation_dossier_paiement(payment)
    @payment = payment
    @projet = @payment.payment_registry.projet
    mail(
      to: @projet.email,
      cc: @projet.personne.try(:email),
      subject: t('mailers.dossier_paiement_mailer.validation.sujet')
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
end
