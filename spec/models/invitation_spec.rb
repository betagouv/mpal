require 'rails_helper'

describe Invitation do
  let(:invitation) { build :invitation }
  let(:projet) { build :projet }
  subject { invitation }

  it { is_expected.to validate_presence_of(:projet) }
  it { is_expected.to validate_presence_of(:intervenant) }
  it { is_expected.to validate_uniqueness_of(:intervenant).scoped_to(:projet_id) }
  it { is_expected.to have_db_column(:intermediaire_id) }

  it { is_expected.to be_valid }

  it { is_expected.to delegate_method(:demandeur).to(:projet) }
  it { is_expected.to delegate_method(:description_adresse).to(:projet) }

  describe '#projet_email' do
    it "devrait retourner l'email du projet" do
      expect(invitation.projet.email).to eq('prenom.nom@site.com')
    end
  end
end
