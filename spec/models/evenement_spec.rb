require "rails_helper"

describe Evenement do
  describe "validations" do
    let(:evenement) { build :evenement }
    it { expect(evenement).to be_valid }
    it { is_expected.to validate_presence_of(:projet) }
    it { is_expected.to validate_presence_of(:label) }
    it { is_expected.to validate_presence_of(:quand) }
    it { is_expected.to belong_to(:producteur) }
  end
end

