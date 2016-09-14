require 'rails_helper'

describe Agent do
  it { expect(FactoryGirl.build(:agent)).to be_valid }

  it { is_expected.to validate_presence_of(:nom) }
  it { is_expected.to validate_presence_of(:prenom) }
  it { is_expected.to belong_to(:intervenant) }
end
