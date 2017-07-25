require 'rails_helper'

describe PaymentMailer, type: :mailer do
  describe "notifie le demandeur qu'une demande de paiement a été supprimée" do
    let(:projet)     { create :projet, :en_cours_d_instruction, :with_trusted_person, :with_payment_registry }
    let(:payment)    { create :payment, payment_registry: projet.payment_registry }
    let(:email)      { PaymentMailer.destruction_dossier_paiement(payment) }

    it { expect(email.from).to eq([ENV['EMAIL_CONTACT']]) }
    it { expect(email.to).to eq([projet.email]) }
    it { expect(email.cc).to eq([projet.personne.email]) }
    it { expect(email.subject).to eq(I18n.t('mailers.dossier_paiement_mailer.destruction.sujet', operateur: projet.operateur.raison_sociale)) }
    it { expect(email.body.encoded).to match(projet.demandeur.fullname) }
    it { expect(email.body.encoded).to match(projet.operateur.raison_sociale) }
    it { expect(email.body).to include("a supprimé la demande de paiement") }
  end

  describe "notifie le demandeur qu'il doit valider la proposition faite par l'opérateur pour lademande demande de paiement" do
    let(:projet)     { create :projet, :en_cours_d_instruction, :with_trusted_person, :with_payment_registry }
    let(:payment)    { create :payment, payment_registry: projet.payment_registry }
    let(:email)      { PaymentMailer.validation_dossier_paiement(payment) }

    it { expect(email.from).to eq([ENV['EMAIL_CONTACT']]) }
    it { expect(email.to).to eq([projet.email]) }
    it { expect(email.cc).to eq([projet.personne.email]) }
    it { expect(email.subject).to eq(I18n.t('mailers.dossier_paiement_mailer.validation.sujet')) }
    it { expect(email.body.encoded).to match(projet.demandeur.fullname) }
    it { expect(email.body.encoded).to match(projet.operateur.raison_sociale) }
    it { expect(email.body).to include("a complété votre demande de paiement") }
  end

  describe "notifie l'instructeur et l'opérateur qu'un demandeur a transmis une demande de paiement" do
    let(:projet)     { create :projet, :en_cours_d_instruction, :with_payment_registry }
    let(:payment)    { create :payment, payment_registry: projet.payment_registry }
    let(:email)      { PaymentMailer.depot_dossier_paiement(payment) }

    it { expect(email.from).to eq([ENV['EMAIL_CONTACT']]) }
    it { expect(email.to).to eq([projet.invited_instructeur.email]) }
    it { expect(email.cc).to eq([projet.operateur.email]) }
    it { expect(email.subject).to eq(I18n.t('mailers.dossier_paiement_mailer.depot.sujet', demandeur: projet.demandeur.fullname)) }
    it { expect(email.body.encoded).to match(projet.demandeur.fullname) }
    it { expect(email.body).to include("déposer la demande de paiement") }
  end

  describe "notifie le demandeur que sa demande a été transmise au service instructeur" do
    let(:projet)     { create :projet, :en_cours_d_instruction, :with_trusted_person, :with_payment_registry }
    let(:payment)    { create :payment, payment_registry: projet.payment_registry }
    subject(:email)  { PaymentMailer.accuse_reception_dossier_paiement(payment) }

    it { expect(email.from).to eq([ENV['EMAIL_CONTACT']]) }
    it { expect(email.to).to eq([projet.email]) }
    it { expect(email.cc).to eq([projet.personne.email]) }
    it { expect(email.subject).to eq(I18n.t('mailers.dossier_paiement_mailer.accuse_reception.sujet')) }
    it { expect(email.body).to include(projet.demandeur.fullname) }
    it { expect(email.body).to include("demande de paiement pour des travaux") }
  end

  describe "notifie l'opérateur que le demandeur souhaite modifier la demande de paiement" do
    let(:projet)     { create :projet, :en_cours_d_instruction, :with_trusted_person, :with_payment_registry }
    let(:payment)    { create :payment, payment_registry: projet.payment_registry }
    subject(:email)  { PaymentMailer.modification_demandeur(payment) }

    it { expect(email.from).to eq([ENV['EMAIL_CONTACT']]) }
    it { expect(email.to).to eq([projet.operateur.email]) }
    it { expect(email.subject).to eq(I18n.t('mailers.dossier_paiement_mailer.modification_demandeur.sujet', demandeur: projet.demandeur.fullname)) }
    it { expect(email.body).to include(projet.demandeur.fullname) }
    it { expect(email.body).to include("souhaite modifier la demande de paiement suivante") }
  end

  describe "notifie l'opérateur que l'instructeur souhaite modifier la demande de paiement" do
    let(:projet)     { create :projet, :en_cours_d_instruction, :with_trusted_person, :with_payment_registry }
    let(:payment)    { create :payment, payment_registry: projet.payment_registry }
    subject(:email)  { PaymentMailer.modification_instructeur(payment) }

    it { expect(email.from).to eq([ENV['EMAIL_CONTACT']]) }
    it { expect(email.to).to eq([projet.operateur.email]) }
    it { expect(email.subject).to eq(I18n.t('mailers.dossier_paiement_mailer.modification_instructeur.sujet', instructeur: projet.invited_instructeur.raison_sociale)) }
    it { expect(email.body).to include(projet.invited_instructeur.raison_sociale) }
    it { expect(email.body).to include("souhaite modifier la demande de paiement suivante") }
  end
end
