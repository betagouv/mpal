require 'rails_helper'

describe ProjetMailer, type: :mailer do
  describe "notifie le demandeur que le PRIS lui recommande des opérateurs" do
    let(:projet) { create :projet, :prospect, :with_suggested_operateurs, :with_invited_pris, :with_trusted_person }
    let(:email)  { ProjetMailer.recommandation_operateurs(projet) }

    it { expect(email.from).to eq([ENV['EMAIL_CONTACT']]) }
    it { expect(email.to).to eq([projet.email]) }
    it { expect(email.cc).to eq([projet.personne.email]) }
    it { expect(email.subject).to eq(I18n.t('mailers.projet_mailer.recommandation_operateurs.sujet')) }
    it { expect(email.body).to include(projet.demandeur.fullname) }
    it { expect(email.body).to include(projet_choix_operateur_url(projet)) }
  end

  describe "notifie l'opérateur de l'invitation du demandeur" do
    let(:invitation) { create :invitation }
    let(:email)      { ProjetMailer.invitation_intervenant(invitation) }

    it { expect(email.from).to eq([ENV['EMAIL_CONTACT']]) }
    it { expect(email.to).to eq([invitation.intervenant.email]) }
    it { expect(email.subject).to eq(I18n.t('mailers.projet_mailer.invitation_intervenant.sujet', demandeur: invitation.demandeur.fullname)) }
    it { expect(email.body).to include(invitation.demandeur.fullname) }
    it { expect(email.body).to include(invitation.description_adresse) }
    it { expect(email.body).to include("Difficultés rencontrées dans le logement") }
    it { expect(email.body).to include(dossier_url(invitation.projet)) }
  end

  describe "notifie le demandeur qu'il a bien invité un opérateur " do
    let(:projet)     { create :projet, :prospect, :with_contacted_operateur, :with_invited_pris, :with_trusted_person }
    let(:invitation) { projet.invitations.where(intervenant: projet.contacted_operateur).first }
    let(:email)      { ProjetMailer.notification_invitation_intervenant(invitation) }

    it { expect(email.from).to eq([ENV['EMAIL_CONTACT']]) }
    it { expect(email.to).to eq([projet.email]) }
    it { expect(email.cc).to eq([projet.personne.email]) }
    it { expect(email.subject).to eq(I18n.t('mailers.projet_mailer.notification_invitation_intervenant.sujet', intervenant: invitation.intervenant.raison_sociale)) }
    it { expect(email.body).to include(invitation.intervenant.raison_sociale) }
    it { expect(email.body).to include("Un email vient d’être envoyé à ") }
  end

  describe "notifie l'opérateur que le demandeur a choisi un autre opérateur" do
    let(:invitation) { create :invitation }
    let(:email)      { ProjetMailer.resiliation_operateur(invitation) }

    it { expect(email.from).to eq([ENV['EMAIL_CONTACT']]) }
    it { expect(email.to).to eq([invitation.intervenant.email]) }
    it { expect(email.subject).to eq(I18n.t('mailers.projet_mailer.resiliation_operateur.sujet', demandeur: invitation.demandeur.fullname)) }
    it { expect(email.body).to include(invitation.demandeur.fullname) }
  end

  describe "notifie l'intervenant qu'il a été choisi par le demandeur" do
    let(:operateur)   { create :operateur }
    let(:projet)      { create :projet, :prospect, operateur: operateur }
    let!(:invitation) { create :invitation, projet: projet, intervenant: operateur }
    let(:email)       { ProjetMailer.notification_engagement_operateur(projet) }

    it { expect(email.from).to eq([ENV['EMAIL_CONTACT']]) }
    it { expect(email.to).to eq([projet.operateur.email]) }
    it { expect(email.subject).to eq(I18n.t('mailers.projet_mailer.notification_engagement_operateur.sujet', intervenant: operateur.raison_sociale, demandeur: projet.demandeur.fullname)) }
    it { expect(email.body).to include(invitation.demandeur.fullname) }
    it { expect(email.body).to include(dossier_url(projet)) }
  end

  describe "notifie le demandeur qu'il doit valider la proposition faite par l'opérateur" do
    let(:projet)     { create :projet, :proposition_proposee, :with_trusted_person }
    let(:prestation) { projet.prestations.first }
    let(:email)      { ProjetMailer.notification_validation_dossier(projet) }

    it { expect(email.from).to eq([ENV['EMAIL_CONTACT']]) }
    it { expect(email.to).to eq([projet.email]) }
    it { expect(email.cc).to eq([projet.personne.email]) }
    it { expect(email.subject).to eq(I18n.t('mailers.projet_mailer.notification_validation_dossier.sujet')) }
    it { expect(email.body).to include(projet.demandeur.fullname) }
    it { expect(email.body).to include(projet.operateur.raison_sociale) }
    it { expect(email.body).to include("a complété votre dossier") }
  end

  describe "notifie l'instructeur qu'un opérateur lui a transmis un dossier" do
    let(:projet)           { create :projet, :transmis_pour_instruction }
    let(:mise_en_relation) { create :mise_en_relation, projet: projet }
    let(:prestation)       { projet.prestations.first }
    let(:email)            { ProjetMailer.mise_en_relation_intervenant(mise_en_relation) }

    it { expect(email.from).to eq([ENV['EMAIL_CONTACT']]) }
    it { expect(email.to).to eq([mise_en_relation.intervenant.email]) }
    it { expect(email.subject).to eq(I18n.t('mailers.projet_mailer.mise_en_relation_intervenant.sujet', intermediaire: mise_en_relation.intermediaire.raison_sociale)) }
    it { expect(email.body).to include(mise_en_relation.description_adresse) }
    it { expect(email.body).to include(prestation.libelle) }
  end

  describe "notifie le demandeur que sa demande a été transmise au service instructeur" do
    let(:projet) { create :projet, :transmis_pour_instruction, :with_trusted_person }
    subject(:email) { ProjetMailer.accuse_reception(projet) }

    it { expect(email.from).to eq([ENV['EMAIL_CONTACT']]) }
    it { expect(email.reply_to).to eq([projet.invited_instructeur.email]) }
    it { expect(email.to).to eq([projet.email]) }
    it { expect(email.cc).to eq([projet.personne.email]) }
    it { expect(email.subject).to eq(I18n.t('mailers.projet_mailer.accuse_reception.sujet')) }
    it { expect(email.body).to include(projet.demandeur.fullname) }
    it { expect(email.body).to include(projet.plateforme_id) }
    it { expect(email.body).to include(projet.invited_instructeur.raison_sociale) }
    it { expect(email.body).to include(projet.invited_instructeur.description_adresse) }
    it { expect(email.body).to include(projet.invited_instructeur.email) }
  end
end

