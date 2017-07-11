require "rails_helper"
require "cancan/matchers"

describe User do
  describe "validations" do
    it { is_expected.to have_many :projets }
  end

  describe "abilities" do
    let(:user)        { create :user }
    subject(:ability) { Ability.new(user, projet) }

    context "when projet is locked" do
      let(:projet) { create :projet, locked_at: Time.new(1789, 7, 14, 16, 0, 0) }

      it { is_expected.not_to be_able_to(:manage, AvisImposition) }
      it { is_expected.not_to be_able_to(:manage, Demande) }
      it { is_expected.not_to be_able_to(:manage, :demandeur) }
      it { is_expected.not_to be_able_to(:manage, Occupant) }
      it { is_expected.not_to be_able_to(:manage, Projet) }
      it { is_expected.not_to be_able_to(:read,   PaymentRegistry) }
    end

    context "when project is not locked" do
      let(:projet) { create :projet, :transmis_pour_instruction, :with_payment_registry }

      it { is_expected.to be_able_to(:manage, AvisImposition) }
      it { is_expected.to be_able_to(:manage, Demande) }
      it { is_expected.to be_able_to(:manage, :demandeur) }
      it { is_expected.to be_able_to(:manage, Occupant) }
      it { is_expected.to be_able_to(:manage, Projet) }
      it { is_expected.to be_able_to(:read,   PaymentRegistry) }
    end
  end

  describe "#projet" do
    let(:user) {    create :user }
    let!(:projet) { create :projet, user: user }
    it { expect(user.projet).to eq(projet) }
  end
end
