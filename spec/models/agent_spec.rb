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
    subject(:ability) { Ability.new(agent, projet) }

    context "when a payment registry exists" do
      let(:agent) { create :agent }
      let(:projet) { create :projet, :transmis_pour_instruction, :with_payment_registry }
      it { is_expected.to be_able_to(:read, PaymentRegistry) }
    end

    describe "when is an operator" do
      context "when the status is prospect and he is contacted by user" do
        let(:agent) { create :agent, intervenant: projet.contacted_operateur }

        context "can read a project but not modify it" do
          let(:projet) { create :projet, :prospect, :with_contacted_operateur }

          it { is_expected.not_to be_able_to(:manage, AvisImposition) }
          it { is_expected.not_to be_able_to(:manage, Demande) }
          it { is_expected.not_to be_able_to(:manage, :demandeur) }
          it { is_expected.not_to be_able_to(:manage, Occupant) }
          it { is_expected.not_to be_able_to(:manage, :eligibility) }
          it { is_expected.to be_able_to(:read, Projet) }
        end
      end

      context "when he is engaged with user" do
        let(:agent) { create :agent, intervenant: projet.operateur }

        context "can manage an entire project he is on until 'transmis pour instruction'" do
          let(:projet) { create :projet, :en_cours}

            it { is_expected.to be_able_to(:manage, AvisImposition) }
            it { is_expected.to be_able_to(:manage, Demande) }
            it { is_expected.to be_able_to(:manage, :demandeur) }
            it { is_expected.to be_able_to(:manage, Occupant) }
          it { is_expected.not_to be_able_to(:manage, :eligibility) }
            it { is_expected.to be_able_to(:manage, Projet) }
          end

        context "can only read after 'transmis pour instruction'" do
          let(:projet) { create :projet, :transmis_pour_instruction }
            it { is_expected.not_to be_able_to(:manage, AvisImposition) }
            it { is_expected.not_to be_able_to(:manage, Demande) }
            it { is_expected.not_to be_able_to(:manage, :demandeur) }
          it { is_expected.not_to be_able_to(:manage, :eligibility) }
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
        let(:agent)  { create :agent, admin: true }
        let(:projet) { create :projet }
        it { is_expected.to be_able_to(:manage, :all) }
      end
    end

    describe "when is an PRIS" do
      let(:agent) { create :agent, intervenant: projet.invited_pris }

      context "before the user is engaged with operator" do
        context "can read a project but not modify it" do
          let(:projet) { create :projet, :prospect, :with_invited_pris }

          it { is_expected.not_to be_able_to(:manage, AvisImposition) }
          it { is_expected.not_to be_able_to(:manage, Demande) }
          it { is_expected.not_to be_able_to(:manage, :demandeur) }
          it { is_expected.not_to be_able_to(:manage, :eligibility) }
          it { is_expected.not_to be_able_to(:manage, Occupant) }
          it { is_expected.to be_able_to(:read, Projet) }
        end
      end

      context "after the user is engaged with operator" do
        context "cannot access or modify a project" do
          let(:projet) { create :projet, :en_cours, :with_invited_pris }

          it { is_expected.not_to be_able_to(:read, AvisImposition) }
          it { is_expected.not_to be_able_to(:read, Demande) }
          it { is_expected.not_to be_able_to(:read, :demandeur) }
          it { is_expected.not_to be_able_to(:manage, :eligibility) }
          it { is_expected.not_to be_able_to(:read, Occupant) }
          it { is_expected.not_to be_able_to(:read, Projet) }
        end
      end
    end

    describe "when is an Instructeur" do
      context "before the project is 'transmis_pour_instruction'" do
        context "cannot read or modify a project" do
          let(:projet)      { create :projet, :prospect, :with_invited_instructeur }
          let(:instructeur) { create :instructeur }
          let(:agent)       { create :agent, intervenant: instructeur }

          it { is_expected.not_to be_able_to(:read, AvisImposition) }
          it { is_expected.not_to be_able_to(:read, Demande) }
          it { is_expected.not_to be_able_to(:read, :demandeur) }
          it { is_expected.not_to be_able_to(:manage, :eligibility) }
          it { is_expected.not_to be_able_to(:read, Occupant) }
          it { is_expected.not_to be_able_to(:read, Projet) }
        end
      end

      context "after the project is 'transmis_pour_instruction'" do
        context "can access project" do
          let(:projet) { create :projet, :transmis_pour_instruction, :with_committed_instructeur }
          let(:agent)  { projet.agent_instructeur }

          it { is_expected.not_to be_able_to(:read, AvisImposition) }
          it { is_expected.not_to be_able_to(:read, Demande) }
          it { is_expected.not_to be_able_to(:read, :demandeur) }
          it { is_expected.not_to be_able_to(:manage, :eligibility) }
          it { is_expected.not_to be_able_to(:read, Occupant) }
          it { is_expected.to be_able_to(:read, Projet) }
        end
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
