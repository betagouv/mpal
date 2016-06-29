require 'rails_helper'

describe Evenement do
  it { is_expected.to validate_presence_of(:projet) }
  it { is_expected.to validate_presence_of(:label) }
  it { is_expected.to validate_presence_of(:quand) }
  it { is_expected.to belong_to(:producteur) }
  it { expect(FactoryGirl.build(:evenement)).to be_valid }
end
