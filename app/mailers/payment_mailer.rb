class PaymentMailer < ApplicationMailer
  def destruction(payment)
    @payment = payment
    @projet  = payment.projet
    mail(
      to: @projet.email,
      cc: @projet.personne.try(:email),
      subject: t('mailers.paiement_mailer.destruction.sujet', operateur: @projet.operateur.raison_sociale)
    )
  end

  def demande_validation(payment)
    @payment = payment
    @projet  = payment.projet
    mail(
      to: @projet.email,
      cc: @projet.personne.try(:email),
      subject: t('mailers.paiement_mailer.demande_validation.sujet')
    )
  end

  def depot(payment, intervenant)
    @payment     = payment
    @projet      = payment.projet
    @intervenant = intervenant
    mail(
      to: intervenant.email,
      subject: t('mailers.paiement_mailer.depot.sujet', demandeur: @projet.demandeur.fullname)
    )
  end

  def accuse_reception_depot(payment)
    @payment = payment
    @projet  = payment.projet
    if @projet.operateur.present?
      bcc_mails = @projet.operateur.try(:username) + " ; "
    end
    bcc_mails += @projet.invited_instructeur.try(:email)
    mail(
      to: @projet.email,
      cc: @projet.personne.try(:email),
      bcc: bcc_mails,
      subject: t('mailers.paiement_mailer.accuse_reception_depot.sujet')
    )
  end

  def correction_depot(payment, intervenant)
    @payment     = payment
    @projet      = payment.projet
    @intervenant = intervenant
    mail(
      to: intervenant.email,
      subject: t('mailers.paiement_mailer.correction_depot.sujet', demandeur: @projet.demandeur.fullname)
    )
  end

  def accuse_reception_correction_depot(payment)
    @payment = payment
    @projet  = payment.projet
    mail(
      to: @projet.email,
      cc: @projet.personne.try(:email),
      subject: t('mailers.paiement_mailer.accuse_reception_correction_depot.sujet')
    )
  end

  def demande_modification(payment, is_from_user)
    @payment = payment
    @projet  = payment.projet

    if is_from_user
      cc = []
      @from_fullname = @projet.demandeur.fullname
    else
      cc = [@projet.email, @projet.personne.try(:email)]
      @from_fullname = @projet.invited_instructeur.raison_sociale
    end

    mail(
      to: @projet.operateur.email,
      cc: cc,
      subject: t('mailers.paiement_mailer.demande_modification.sujet', from_fullname: @from_fullname)
    )
  end
end
