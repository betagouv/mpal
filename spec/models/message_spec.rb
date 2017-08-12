require "rails_helper"

describe Message do
  let(:message) { FactoryGirl.build(:message)}
  it { expect(FactoryGirl.build(:message)).to be_valid }

  it { is_expected.to validate_presence_of(:auteur) }
  it { is_expected.to validate_presence_of(:projet) }
  it { is_expected.to validate_presence_of(:corps_message) }
  it { is_expected.to belong_to(:projet) }
end

