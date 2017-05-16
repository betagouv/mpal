require 'rails_helper'
require 'support/after_party_helper'

describe '20170511152048_migrate_uncommited_operateurs' do
  include_context 'after_party'

  let(:projet)              { create :projet }
  let(:suggested_operateur) { create :operateur }
  let(:contacted_operateur) { create :operateur }
  let(:pris)                { create :pris }
  let!(:contact_invitation) { create :invitation, projet: projet, intervenant: contacted_operateur }
  let!(:invitation_pris)    { create :invitation, projet: projet, intervenant: pris }

  before do
    projet.suggested_operateurs << suggested_operateur
    subject.invoke
  end

  shared_examples "met à jour les invitations d'opérateurs" do
    specify do
      suggestion_invitation = Invitation.find_by(intervenant_id: suggested_operateur.id)
      contact_invitation.reload
      invitation_pris.reload

      expect(suggestion_invitation.suggested).to eq true
      expect(suggestion_invitation.contacted).to eq false

      expect(contact_invitation.suggested).to eq false
      expect(contact_invitation.contacted).to eq true

      expect(invitation_pris.suggested).to eq false
      expect(invitation_pris.contacted).to eq false
    end
  end

  it "charge l'environment Rails" do
    expect(subject.prerequisites).to include 'environment'
  end

  it_behaves_like "met à jour les invitations d'opérateurs"

  context "si appelé plusieurs fois" do
    before { subject.invoke }
    it_behaves_like "met à jour les invitations d'opérateurs"
  end
end
