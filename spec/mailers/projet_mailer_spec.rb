require 'rails_helper'

describe ProjetMailer do
  describe "invitation intervenant" do
    let(:invitation) { FactoryGirl.create(:invitation) }
    let(:email) { ProjetMailer.invitation_intervenant(invitation) }
    it { expect(email.from).to eq(['no-reply@mpal.beta.gouv.fr']) }
    it { expect(email.to).to eq([invitation.intervenant_email]) }
    it { expect(email.subject).to eq(I18n.t('mailers.projet_mailer.invitation_intervenant.sujet', usager: invitation.usager)) }
    it { expect(email.body.encoded).to match(invitation.usager) }
    it { expect(email.body.encoded).to match(invitation.adresse) }
    it { expect(email.body.encoded).to match(invitation.description) }
    xit { expect(email.body.encoded).to match(projet_url(invitation.projet, jeton: invitation.token)) }
  end
end
