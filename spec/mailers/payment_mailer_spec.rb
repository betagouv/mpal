require 'rails_helper'

describe PaymentMailer, type: :mailer do
  describe "notifie le demandeur qu'il doit valider la proposition faite par l'opérateur pour le dossier de paiement" do
    let(:projet)     { create :projet, :en_cours_d_instruction, :with_trusted_person, :with_payment_registry }
    let(:payment)    { create :payment, payment_registry: projet.payment_registry }
    let(:email)      { PaymentMailer.notification_validation_dossier_paiement(payment) }

    it { expect(email.from).to eq([ENV['EMAIL_CONTACT']]) }
    it { expect(email.to).to eq([projet.email]) }
    it { expect(email.cc).to eq([projet.personne.email]) }
    it { expect(email.subject).to eq(I18n.t('mailers.dossier_paiement_mailer.notification_validation_dossier_paiement.sujet')) }
    it { expect(email.body.encoded).to match(projet.demandeur.fullname) }
    it { expect(email.body.encoded).to match(projet.operateur.raison_sociale) }
    it { expect(email.body).to include("a complété votre demande de paiement") }
  end

  describe "notifie l'instructeur et l'opérateur qu'un demandeur a transmis un dossier de paiement" do
    let(:projet)     { create :projet, :en_cours_d_instruction, :with_payment_registry }
    let(:payment)    { create :payment, payment_registry: projet.payment_registry }
    let(:email)   { PaymentMailer.depot_dossier_paiement(payment) }

    it { expect(email.from).to eq([ENV['EMAIL_CONTACT']]) }
    it { expect(email.to).to eq([projet.invited_instructeur.email]) }
    it { expect(email.cc).to eq([projet.operateur.email]) }
    it { expect(email.subject).to eq(I18n.t('mailers.dossier_paiement_mailer.depot_dossier_paiement.sujet', demandeur: projet.demandeur.fullname)) }
    it { expect(email.body.encoded).to match(projet.demandeur.fullname) }
    it { expect(email.body).to include("déposer le dosssier de paiement") }
  end

  describe "notifie le demandeur que sa demande a été transmise au service instructeur" do
    let(:projet)     { create :projet, :en_cours_d_instruction, :with_trusted_person, :with_payment_registry }
    let(:payment)    { create :payment, payment_registry: projet.payment_registry }
    subject(:email) { PaymentMailer.accuse_reception_dossier_paiement(payment) }

    it { expect(email.from).to eq([ENV['EMAIL_CONTACT']]) }
    it { expect(email.to).to eq([projet.email]) }
    it { expect(email.cc).to eq([projet.personne.email]) }
    it { expect(email.subject).to eq(I18n.t('mailers.dossier_paiement_mailer.accuse_reception.sujet')) }
    it { expect(email.body).to include(projet.demandeur.fullname) }
    it { expect(email.body).to include("demande de paiement pour des travaux") }
  end

  describe "notifie l'opérateur que le demandeur souhaite modifier le dossier de paiement" do
    let(:projet)     { create :projet, :en_cours_d_instruction, :with_trusted_person, :with_payment_registry }
    let(:payment)    { create :payment, payment_registry: projet.payment_registry }
    subject(:email) { PaymentMailer.demande_modification(payment) }

    it { expect(email.from).to eq([ENV['EMAIL_CONTACT']]) }
    it { expect(email.to).to eq([projet.operateur.email]) }
    it { expect(email.subject).to eq(I18n.t('mailers.dossier_paiement_mailer.demande_modification.sujet', demandeur: projet.demandeur.fullname)) }
    it { expect(email.body).to include(projet.demandeur.fullname) }
    it { expect(email.body).to include("souhaite modifier la demande de paiement suivante") }
  end

  #    VERIFIER AVEC CELINE L'UTILITE DE FAIRE CA
  # describe "notifie le demandeur de la suppression d'une demande de paiement" do
  #   let(:projet)    { create :projet, :en_cours_d_instruction, :with_trusted_person, :with_payment_registry }
  #   let(:payment)   { create :payment, payment_registry: projet.payment_registry }
  #   subject(:email) { PaymentMailer.suppression_dossier_paiement(payment) }
  #
  #   it { expect(email.from).to eq([ENV['EMAIL_CONTACT']]) }
  #   it { expect(email.to).to eq([projet.email]) }
  #   it { expect(email.cc).to eq([projet.personne.email]) }
  #   it { expect(email.subject).to eq(I18n.t('mailers.dossier_paiement_mailer.suppression_dossier_paiement.sujet')) }
  #   it { expect(email.body).to include(projet.demandeur.fullname) }
  #   it { expect(email.body).to include("") }
  # end

end
