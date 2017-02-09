require 'rails_helper'

describe ProjetMailer, type: :mailer do
  describe "invitation intervenant" do
    let(:invitation) { create :invitation }
    let(:email) { ProjetMailer.invitation_intervenant(invitation) }
    it { expect(email.from).to eq([ENV['NO_REPLY_FROM']]) }
    it { expect(email.to).to eq([invitation.intervenant_email]) }
    it { expect(email.subject).to eq(I18n.t('mailers.projet_mailer.invitation_intervenant.sujet', demandeur_principal: invitation.demandeur_principal.fullname)) }
    it { expect(email.body.encoded).to match(invitation.demandeur_principal.fullname) }
    it { expect(email.body.encoded).to match(invitation.adresse) }
    it { expect(email.body.encoded).to include("Difficultés rencontrées dans le logement") }
    it { expect(email.body.encoded).to include(dossier_url(invitation.projet)) }
  end

  describe "mise en relation intervenant" do
    let(:mise_en_relation) { create :mise_en_relation }
    let(:email) { ProjetMailer.mise_en_relation_intervenant(mise_en_relation) }
    it { expect(email.from).to eq([ENV['NO_REPLY_FROM']]) }
    it { expect(email.to).to eq([mise_en_relation.intervenant_email]) }
    it { expect(email.subject).to eq(I18n.t('mailers.projet_mailer.mise_en_relation_intervenant.sujet', intermediaire: mise_en_relation.intermediaire)) }
  end

  describe "l'opérateur reçoit un email lorsque le demandeur choisit un autre opérateur" do
    let(:invitation) { create :invitation }
    let(:email) { ProjetMailer.resiliation_operateur(invitation) }
    it { expect(email.from).to eq([ENV['NO_REPLY_FROM']]) }
    it { expect(email.to).to eq([invitation.intervenant_email]) }
    it { expect(email.subject).to eq(I18n.t('mailers.projet_mailer.resiliation_operateur.sujet', demandeur_principal: invitation.demandeur_principal.fullname)) }
    it { expect(email.body.encoded).to match(invitation.demandeur_principal.fullname) }
  end

  describe "le PRIS reçoit un email lorsque le demandeur choisit un opérateur" do
    let(:projet)     { create :projet, :with_invited_operateur }
    let(:operateur)  { projet.invited_operateur }
    let(:pris)       { create :pris }
    let(:invitation) { create :invitation, projet: projet, intervenant: pris }
    let(:email) { ProjetMailer.resiliation_pris(invitation, operateur) }
    it { expect(email.from).to eq([ENV['NO_REPLY_FROM']]) }
    it { expect(email.to).to eq([pris.email]) }
    it { expect(email.subject).to eq(I18n.t('mailers.projet_mailer.resiliation_pris.sujet', demandeur_principal: invitation.demandeur_principal.fullname)) }
    it { expect(email.body.encoded).to match(invitation.demandeur_principal.fullname) }
    it { expect(email.body.encoded).to match(operateur.raison_sociale) }
    it { expect(email.body.encoded).to include(dossier_url(projet)) }
  end

  describe "l'intervenant reçoit un email lorsqu'il a été choisi par le demandeur" do
    let(:operateur) { create :operateur }
    let(:projet) { create :projet, operateur: operateur }
    let!(:invitation) { create :invitation, projet: projet, intervenant: operateur }
    let(:email) { ProjetMailer.notification_choix_intervenant(projet) }
    it { expect(email.from).to eq([ENV['NO_REPLY_FROM']]) }
    it { expect(email.to).to eq([projet.operateur.email]) }
    it { expect(email.subject).to eq(I18n.t('mailers.projet_mailer.notification_choix_intervenant.sujet', intervenant: operateur, demandeur_principal: projet.demandeur_principal.fullname)) }
    it { expect(email.body.encoded).to match(invitation.demandeur_principal.fullname) }
    it { expect(email.body.encoded).to include(dossier_url(projet)) }
   end
end
