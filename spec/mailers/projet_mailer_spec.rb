require 'rails_helper'

describe ProjetMailer, type: :mailer do
  describe "invitation intervenant" do
    let(:invitation) { FactoryGirl.create(:invitation) }
    let(:email) { ProjetMailer.invitation_intervenant(invitation) }
    it { expect(email.from).to eq(['no-reply@mpal.beta.gouv.fr']) }
    it { expect(email.to).to eq([invitation.intervenant_email]) }
    it { expect(email.subject).to eq(I18n.t('mailers.projet_mailer.invitation_intervenant.sujet', demandeur_principal: invitation.demandeur_principal)) }
    it { expect(email.body.encoded).to match(invitation.demandeur_principal.to_s) }
    it { expect(email.body.encoded).to match(invitation.adresse) }
    it { expect(email.body.encoded).to include("Difficultés rencontrées dans le logement") }
    it { expect(email.body.encoded).to include(projet_url(invitation.projet, jeton: invitation.token)) }
  end

  describe "mise en relation intervenant" do
    let(:mise_en_relation) { FactoryGirl.create(:mise_en_relation) }
    let(:email) { ProjetMailer.mise_en_relation_intervenant(mise_en_relation) }
    it { expect(email.from).to eq(['no-reply@mpal.beta.gouv.fr']) }
    it { expect(email.to).to eq([mise_en_relation.intervenant_email]) }
    it { expect(email.subject).to eq(I18n.t('mailers.projet_mailer.mise_en_relation_intervenant.sujet', intermediaire: mise_en_relation.intermediaire)) }
  end

  describe "l'intervenant reçoit un e-mail lorsqu'il a été choisi par le demandeur" do
   it "le mail contient un sujet" do
     @projet = FactoryGirl.create(:projet)
     operateur = FactoryGirl.create(:intervenant, :operateur)
     invitation = FactoryGirl.create(:invitation, projet: @projet, intervenant: operateur)
     @projet.operateur = operateur
     email = ProjetMailer.notification_choix_intervenant(@projet)

     expect(email.from).to eq(['no-reply@mpal.beta.gouv.fr'])
     expect(email.to).to eq([@projet.operateur.email])
     expect(email.subject).to eq(I18n.t('mailers.projet_mailer.notification_choix_intervenant.sujet', intervenant: operateur, demandeur_principal: @projet.demandeur_principal))
     expect(email.body.encoded).to match(invitation.demandeur_principal.to_s)
     expect(email.body.encoded).to include(projet_url(@projet, jeton: invitation.token))
   end

  end

end
