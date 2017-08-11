require 'rails_helper'

describe Document do
  it { expect(FactoryGirl.create(:document)).to be_valid }

  it { is_expected.to validate_presence_of(:label) }
  it { is_expected.to validate_presence_of(:fichier) }
  it { is_expected.to belong_to(:projet) }
end
