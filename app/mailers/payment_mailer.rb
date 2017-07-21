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
      subject: t('mailers.dossier_paiement_mailer.depot.sujet', demandeur: @projet.demandeur.fullname)
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

  def demande_modification_demandeur(payment)
    @payment = payment
    @projet = @payment.payment_registry.projet
    mail(
        to: @projet.operateur.email,
        subject: t('mailers.dossier_paiement_mailer.demande_modification_demandeur.sujet', demandeur: @projet.demandeur.fullname)
    )
  end

  def demande_modification_instructeur(payment)
    @payment = payment
    @projet = @payment.payment_registry.projet
    mail(
        to: @projet.operateur.email,
        subject: t('mailers.dossier_paiement_mailer.demande_modification_instructeur.sujet', instructeur: @projet.invited_instructeur.raison_sociale)
    )
  end
end
