require 'rails_helper'

describe Occupant do
  let(:occupant) { FactoryGirl.build(:occupant) }
  it { expect(FactoryGirl.build(:occupant)).to be_valid }

  it { is_expected.to validate_presence_of(:nom) }
  it { is_expected.to validate_presence_of(:prenom) }
  it { is_expected.to have_db_column(:lien_demandeur) }
  it { is_expected.to have_db_column(:civilite) }
  it { is_expected.to have_db_column(:demandeur) }
  it { is_expected.to validate_presence_of(:date_de_naissance) }
  it { is_expected.to belong_to(:projet) }
end
