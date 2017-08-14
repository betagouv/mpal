require "rails_helper"

describe Document do
  describe "validations" do
    let(:document) { build :document }
    it { expect(document).to be_valid }
    it { is_expected.to validate_presence_of(:label) }
    it { is_expected.to validate_presence_of(:fichier) }
    it { is_expected.to belong_to(:projet) }
  end
end

