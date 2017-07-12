require "rails_helper"
require "cancan/matchers"
require "support/mpal_features_helper"

describe Agent do
  describe "validations" do
    let(:agent) { build :agent }
    it { expect(agent).to be_valid }
    it { is_expected.to validate_presence_of :nom }
    it { is_expected.to validate_presence_of :prenom }
    it { is_expected.to belong_to :intervenant }
  end

  describe "abilities" do
    let(:agent)       { create :agent }
    subject(:ability) { Ability.new(agent, projet) }

    context "when a payment registry exists" do
      let(:projet) { create :projet, :transmis_pour_instruction, :with_payment_registry }
      it { is_expected.to be_able_to(:read, PaymentRegistry) }
    end

    describe "when is an operator" do
      context "when the status is prospect and he is contacted by user" do
        let(:operateur) { projet.contacted_operateur }
        before {agent.update! intervenant: operateur}

        context "can read a project but not modify it" do
          let(:projet) { create :projet, :prospect, :with_contacted_operateur }

          it { is_expected.not_to be_able_to(:manage, AvisImposition) }
          it { is_expected.not_to be_able_to(:manage, Demande) }
          it { is_expected.not_to be_able_to(:manage, :demandeur) }
          it { is_expected.not_to be_able_to(:manage, Occupant) }
          it { is_expected.to be_able_to(:read, Projet) }
        end
      end

      context "wwhen he is engaged with user" do
        let(:operateur) { projet.operateur }
        before {agent.update! intervenant: operateur}

        context "can manage an entire project he is on until 'transmis pour instruction'" do
          let(:projet) { create :projet, :en_cours}

            it { is_expected.to be_able_to(:manage, AvisImposition) }
            it { is_expected.to be_able_to(:manage, Demande) }
            it { is_expected.to be_able_to(:manage, :demandeur) }
            it { is_expected.to be_able_to(:manage, Occupant) }
            it { is_expected.to be_able_to(:manage, Projet) }
          end

        context "can only read after 'transmis pour instruction'" do
          let(:projet) { create :projet, :transmis_pour_instruction }
            it { is_expected.not_to be_able_to(:manage, AvisImposition) }
            it { is_expected.not_to be_able_to(:manage, Demande) }
            it { is_expected.not_to be_able_to(:manage, :demandeur) }
            it { is_expected.not_to be_able_to(:manage, Occupant) }
            it { is_expected.not_to be_able_to(:manage, Projet) }
            it { is_expected.to be_able_to(:read, Projet) }
          end

        context "when a payment registry doesn't exist" do
          let(:projet) { create :projet, :transmis_pour_instruction }
          it { is_expected.to be_able_to(:create, PaymentRegistry) }
        end

        context "when a payment registry exists" do
          let(:projet) { create :projet, :transmis_pour_instruction, :with_payment_registry }
          it { is_expected.not_to be_able_to(:create, PaymentRegistry) }
        end
      end

      context "when is an admin" do
        let(:projet) { create :projet }
        before { agent.update! admin: true }
        it { is_expected.to be_able_to(:manage, :all) }
      end
    end
  end

  describe "#cas_extra_attributes=" do
    let(:prenom) { "Jean" }
    let(:nom) { "Durand" }
    let(:service_id) { "someserviceid" }
    let(:agent) { build :agent }
    let!(:intervenant) { create :intervenant, clavis_service_id: service_id }
    before { agent.cas_extra_attributes = { Prenom: prenom, Nom: nom, ServiceId: service_id } }
    it "should translate successfully" do
      expect(agent.prenom).to eq(prenom)
      expect(agent.nom).to eq(nom)
      expect(agent.intervenant).to eq(intervenant)
    end
  end

  describe "#fullname" do
    let!(:agent) { build :agent }
    it { expect(agent.fullname).to eq("Joelle Dupont") }
    context "supprime les espaces inutiles" do
      before {
        agent.prenom = " Jean "
        agent.save!
      }
      it { expect(agent.fullname).to eq("Jean Dupont") }
    end
  end
end
