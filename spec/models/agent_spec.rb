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

    describe "other abilities" do
      context "as admin agent" do
        let(:agent)  { create :agent, admin: true }
        let(:projet) { create :projet }
        it { is_expected.to be_able_to(:manage, :all) }
      end

      context "as operator" do
        context "when the status is prospect and he is contacted by user" do
          let(:agent) { create :agent, intervenant: projet.contacted_operateur }

          context "can read a project but not modify it" do
            let(:projet) { create :projet, :prospect, :with_contacted_operateur }

            it { is_expected.not_to be_able_to(:manage, AvisImposition) }
            it { is_expected.not_to be_able_to(:manage, Demande) }
            it { is_expected.not_to be_able_to(:manage, :demandeur) }
            it { is_expected.not_to be_able_to(:manage, Occupant) }
            it { is_expected.not_to be_able_to(:manage, :eligibility) }
            it { is_expected.to     be_able_to(:read, Projet) }
          end
        end

        context "when he is engaged with user" do
          let(:agent) { create :agent, intervenant: projet.operateur }

          context "can manage an entire project he is on until 'transmis pour instruction'" do
            let(:projet) { create :projet, :en_cours}

            it { is_expected.to     be_able_to(:manage, AvisImposition) }
            it { is_expected.to     be_able_to(:manage, Demande) }
            it { is_expected.to     be_able_to(:manage, :demandeur) }
            it { is_expected.to     be_able_to(:manage, Occupant) }
            it { is_expected.not_to be_able_to(:manage, :eligibility) }
            it { is_expected.to     be_able_to(:manage, Projet) }
          end

          context "can only read after 'transmis pour instruction'" do
            let(:projet) { create :projet, :transmis_pour_instruction }

            it { is_expected.not_to be_able_to(:manage, AvisImposition) }
            it { is_expected.not_to be_able_to(:manage, Demande) }
            it { is_expected.not_to be_able_to(:manage, :demandeur) }
            it { is_expected.not_to be_able_to(:manage, :eligibility) }
            it { is_expected.not_to be_able_to(:manage, Occupant) }
            it { is_expected.not_to be_able_to(:manage, Projet) }
            it { is_expected.to     be_able_to(:read, Projet) }
          end
        end
      end

      describe "as PRIS" do
        let(:agent) { create :agent, intervenant: projet.invited_pris }

        context "before the user is engaged with operator" do
          context "can read a project but not modify it" do
            let(:projet) { create :projet, :prospect, :with_invited_pris }

            it { is_expected.not_to be_able_to(:manage, AvisImposition) }
            it { is_expected.not_to be_able_to(:manage, Demande) }
            it { is_expected.not_to be_able_to(:manage, :demandeur) }
            it { is_expected.not_to be_able_to(:manage, :eligibility) }
            it { is_expected.not_to be_able_to(:manage, Occupant) }
            it { is_expected.to     be_able_to(:read, Projet) }
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

      context "as instructor" do
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
            it { is_expected.to     be_able_to(:read, Projet) }
          end
        end
      end
    end

    describe "Payments abilities" do
      context "when a payment registry doesn't exist" do
        let(:projet) { create :projet, :transmis_pour_instruction }

        context "as operator" do
          let(:agent) { create :agent, intervenant: projet.operateur }

          context "with a project not transmited yet to instructor" do
            let(:projet) { create :projet, :proposition_proposee }
            it { is_expected.not_to be_able_to(:create, PaymentRegistry) }
          end

          context "with a project already transmited to instructor" do
            it { is_expected.to be_able_to(:create, PaymentRegistry) }
          end
        end

        context "as instructor" do
          let(:agent) { create :agent, intervenant: projet.invited_instructeur }
          it { is_expected.not_to be_able_to(:create, PaymentRegistry) }
        end
      end

      context "when a payment registry exists" do
        let(:projet)                         { create :projet, :transmis_pour_instruction, :with_payment_registry }

        let(:payment_en_cours_de_montage)    { create :payment, statut: :en_cours_de_montage }
        let(:payment_propose)                { create :payment, statut: :propose }
        let(:payment_demande)                { create :payment, statut: :demande }
        let(:payment_en_cours_d_instruction) { create :payment, statut: :en_cours_d_instruction }
        let(:payment_paye)                   { create :payment, statut: :paye }

        let(:payment_a_rediger)              { create :payment, action: :a_rediger }
        let(:payment_a_modifier)             { create :payment, action: :a_modifier }
        let(:payment_a_valider)              { create :payment, action: :a_valider }
        let(:payment_a_instruire)            { create :payment, action: :a_instruire }
        let(:payment_no_action)              { create :payment, action: :aucune }

        before do
          projet.payment_registry.payments << [ payment_en_cours_de_montage,
                                                payment_propose,
                                                payment_demande,
                                                payment_en_cours_d_instruction,
                                                payment_paye,
                                                payment_a_rediger,
                                                payment_a_modifier,
                                                payment_a_valider,
                                                payment_a_instruire,
                                                payment_no_action,
          ]
        end

        context "as agent" do
          let(:agent) { create :agent }
          it { is_expected.to     be_able_to(:read,   PaymentRegistry) }
          it { is_expected.not_to be_able_to(:create, PaymentRegistry) }
        end

        context "as operator" do
          let(:agent) { create :agent, intervenant: projet.operateur }

          it { is_expected.to     be_able_to(:add,                  Payment) }
          it { is_expected.to     be_able_to(:read,                 Payment) }
          it { is_expected.not_to be_able_to(:ask_for_validation,   Payment) }
          it { is_expected.not_to be_able_to(:ask_for_modification, Payment) }
          it { is_expected.not_to be_able_to(:ask_for_instruction,  Payment) }
          it { is_expected.not_to be_able_to(:send_in_opal,         Payment) }

          it { is_expected.to     be_able_to(:modify, payment_a_rediger) }
          it { is_expected.to     be_able_to(:modify, payment_a_modifier) }
          it { is_expected.not_to be_able_to(:modify, payment_a_valider) }
          it { is_expected.not_to be_able_to(:modify, payment_a_instruire) }
          it { is_expected.not_to be_able_to(:modify, payment_no_action) }

          it { is_expected.to     be_able_to(:destroy, payment_a_rediger) }
          it { is_expected.to     be_able_to(:destroy, payment_a_modifier) }
          it { is_expected.not_to be_able_to(:destroy, payment_a_valider) }
          it { is_expected.not_to be_able_to(:destroy, payment_a_instruire) }
          it { is_expected.not_to be_able_to(:destroy, payment_no_action) }

          it { is_expected.to     be_able_to(:destroy, payment_en_cours_de_montage) }
          it { is_expected.to     be_able_to(:destroy, payment_propose) }
          it { is_expected.not_to be_able_to(:destroy, payment_demande) }
          it { is_expected.not_to be_able_to(:destroy, payment_en_cours_d_instruction) }
          it { is_expected.not_to be_able_to(:destroy, payment_paye) }

          context "when status not yet en_cours_d_instruction" do
            let(:projet) { create :projet, :transmis_pour_instruction, :with_payment_registry }

            it { is_expected.not_to be_able_to(:ask_for_validation, Payment) }
          end

          context "when status has been en_cours_d_instruction" do
            let(:projet) { create :projet, :en_cours_d_instruction, :with_payment_registry }

            it { is_expected.to     be_able_to(:ask_for_validation, payment_a_rediger) }
            it { is_expected.to     be_able_to(:ask_for_validation, payment_a_modifier) }
            it { is_expected.not_to be_able_to(:ask_for_validation, payment_a_valider) }
            it { is_expected.not_to be_able_to(:ask_for_validation, payment_a_instruire) }
            it { is_expected.not_to be_able_to(:ask_for_validation, payment_no_action) }
          end
        end

        context "as instructor" do
          let(:agent) { create :agent, intervenant: projet.invited_instructeur }

          it { is_expected.not_to be_able_to(:add,                  Payment) }
          it { is_expected.not_to be_able_to(:modify,               Payment) }
          it { is_expected.not_to be_able_to(:destroy,              Payment) }
          it { is_expected.not_to be_able_to(:ask_for_validation,   Payment) }
          it { is_expected.not_to be_able_to(:ask_for_instruction,  Payment) }

          it { is_expected.not_to be_able_to(:read, payment_en_cours_de_montage) }
          it { is_expected.not_to be_able_to(:read, payment_propose) }
          it { is_expected.to     be_able_to(:read, payment_demande) }
          it { is_expected.to     be_able_to(:read, payment_en_cours_d_instruction) }
          it { is_expected.to     be_able_to(:read, payment_paye) }

          it { is_expected.not_to be_able_to(:ask_for_modification, payment_a_rediger) }
          it { is_expected.not_to be_able_to(:ask_for_modification, payment_a_modifier) }
          it { is_expected.not_to be_able_to(:ask_for_modification, payment_a_valider) }
          it { is_expected.to     be_able_to(:ask_for_modification, payment_a_instruire) }
          it { is_expected.not_to be_able_to(:ask_for_modification, payment_no_action) }

          it { is_expected.not_to be_able_to(:send_in_opal, payment_a_rediger) }
          it { is_expected.not_to be_able_to(:send_in_opal, payment_a_modifier) }
          it { is_expected.not_to be_able_to(:send_in_opal, payment_a_valider) }
          it { is_expected.to     be_able_to(:send_in_opal, payment_a_instruire) }
          it { is_expected.not_to be_able_to(:send_in_opal, payment_no_action) }
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
