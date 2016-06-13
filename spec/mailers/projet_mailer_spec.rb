require 'rails_helper'

describe ProjetMailer do
  describe "invitation operateur" do
    let(:projet) { FactoryGirl.build(:projet, description: 'Je veux changer de chaudière') }
    let(:operateur) { FactoryGirl.build(:operateur, email: 'contact@monoperateur.com') }
    let(:email) { ProjetMailer.invitation_operateur(projet, operateur) }
    it { expect(email.from).to eq(['no-reply@mpal.beta.gouv.fr']) }
    it { expect(email.to).to eq(['contact@monoperateur.com']) }
    it { expect(email.subject).to eq(I18n.t('mailers.projet_mailer.invitation_operateur.sujet', usager: projet.usager)) }
    it { expect(email.body.encoded).to match(projet.usager) }
    it { expect(email.body.encoded).to match(projet.adresse) }
    it { expect(email.body.encoded).to match(projet.description) }
  end
end
