class PaymentMailer < ActionMailer::Base
  default delivery_method: Proc.new { Rails.env.production? && !Tools.demo? ? :smtp : :letter_opener_web }
  default from: ENV["EMAIL_CONTACT"]

  def destruction(payment)
    @payment = payment
    @projet = @payment.payment_registry.projet
    mail(
      to: @projet.email,
      cc: @projet.personne.try(:email),
      subject: t('mailers.paiement_mailer.destruction.sujet', operateur: @projet.operateur.raison_sociale)
    )
  end

  def demande_validation(payment)
    @payment = payment
    @projet = @payment.payment_registry.projet
    mail(
      to: @projet.email,
      cc: @projet.personne.try(:email),
      subject: t('mailers.paiement_mailer.demande_validation.sujet')
    )
  end

  def depot(payment)
    @payment = payment
    @projet = @payment.payment_registry.projet
    mail(
      to: @projet.invited_instructeur.email,
      cc: @projet.operateur.email,
      subject: t('mailers.paiement_mailer.depot.sujet', demandeur: @projet.demandeur.fullname)
    )
  end

  def accuse_reception_depot(payment)
    @payment = payment
    @projet = @payment.payment_registry.projet
    mail(
      to: @projet.email,
      cc: @projet.personne.try(:email),
      subject: t('mailers.paiement_mailer.accuse_reception_depot.sujet')
    )
  end

  def correction_depot(payment)
    @payment = payment
    @projet = @payment.payment_registry.projet
    mail(
      to: @projet.invited_instructeur.email,
      cc: @projet.operateur.email,
      subject: t('mailers.paiement_mailer.correction_depot.sujet', demandeur: @projet.demandeur.fullname)
    )
  end

  def accuse_reception_correction_depot(payment)
    @payment = payment
    @projet = @payment.payment_registry.projet
    mail(
      to: @projet.email,
      cc: @projet.personne.try(:email),
      subject: t('mailers.paiement_mailer.accuse_reception_correction_depot.sujet')
    )
  end

  def demande_modification_demandeur(payment)
    @payment = payment
    @projet = @payment.payment_registry.projet
    mail(
      to: @projet.operateur.email,
      subject: t('mailers.paiement_mailer.demande_modification_demandeur.sujet', demandeur: @projet.demandeur.fullname)
    )
  end

  def demande_modification_instructeur(payment)
    @payment = payment
    @projet = @payment.payment_registry.projet
    mail(
      to: @projet.operateur.email,
      cc: [@projet.email, @projet.personne.try(:email)],
      subject: t('mailers.paiement_mailer.demande_modification_instructeur.sujet', instructeur: @projet.invited_instructeur.raison_sociale)
    )
  end
end
