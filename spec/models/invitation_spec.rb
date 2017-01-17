require 'rails_helper'

describe Invitation do
  let(:invitation) { FactoryGirl.build(:invitation) }
  let(:projet) { FactoryGirl.build(:projet) }
  subject { invitation }

  it { is_expected.to validate_presence_of(:projet) }
  it { is_expected.to validate_presence_of(:intervenant) }
  it { is_expected.to validate_uniqueness_of(:intervenant).scoped_to(:projet_id) }
  it { is_expected.to have_db_column(:intermediaire_id) }

  it { is_expected.to be_valid }

  it "genere un jeton avant la création" do
    expect(FactoryGirl.create(:invitation).token).to be_present
  end

  it { is_expected.to delegate_method(:demandeur_principal).to(:projet) }
  it { is_expected.to delegate_method(:adresse).to(:projet) }

  describe '#projet_email' do
    it "devrait retourner l'email du projet" do
      invitation.projet = projet
      expect(invitation.projet_email).to eq('prenom.nom@site.com')
    end
  end
end
