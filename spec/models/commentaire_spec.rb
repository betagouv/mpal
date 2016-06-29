require 'rails_helper'

describe Commentaire do
  let(:commentaire) { FactoryGirl.build(:commentaire)}
  it { expect(FactoryGirl.build(:commentaire)).to be_valid }

  it { is_expected.to validate_presence_of(:auteur) }
  it { is_expected.to validate_presence_of(:projet) }
  it { is_expected.to validate_presence_of(:corps_message) }
  it { is_expected.to belong_to(:projet) }
end
