require "rails_helper"

describe User do
  describe "validations" do
    it { is_expected.to have_many :projets }
  end

  describe '#projet' do
    let(:user) {    create :user }
    let!(:projet) { create :projet, user: user }
    it { expect(user.projet).to eq(projet) }
  end
end
