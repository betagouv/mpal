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

    describe "autres abilities" do
      context "en tant qu'agent admin" do
        let(:agent)  { create :agent, admin: true }
        let(:projet) { create :projet }
        it { is_expected.to be_able_to(:manage, :all) }
      end

      context "en tant qu'opérateur" do
        context "quand le statut est 'prospect' et qu'il est contacté par le demandeur" do
          let(:agent) { create :agent, intervenant: projet.contacted_operateur }

          context "il peut lire un projet mais pas le modifier" do
            let(:projet) { create :projet, :prospect, :with_contacted_operateur }

            it { is_expected.not_to be_able_to(:read, AvisImposition) }
            it { is_expected.not_to be_able_to(:read, Demande) }
            it { is_expected.not_to be_able_to(:read, :demandeur) }
            it { is_expected.not_to be_able_to(:read, Document) }
            it { is_expected.not_to be_able_to(:destroy, Document) }
            it { is_expected.not_to be_able_to(:read, Occupant) }
            it { is_expected.not_to be_able_to(:read, :eligibility) }

            it { is_expected.to be_able_to(:read, Projet) }
          end
        end

        context "quand il est engagé avec le demandeur" do
          let(:agent) { create :agent, intervenant: projet.operateur }

          context "il peut gérer le projet jusqu'à ce qu'il soit 'transmis pour instruction'" do
            let(:projet) { create :projet, :en_cours}

            it { is_expected.not_to be_able_to(:manage, :eligibility) }

            it { is_expected.to be_able_to(:manage, AvisImposition) }
            it { is_expected.to be_able_to(:manage, Demande) }
            it { is_expected.to be_able_to(:manage, :demandeur) }
            it { is_expected.to be_able_to(:manage, Occupant) }
            it { is_expected.to be_able_to(:update, Document) }
            it { is_expected.to be_able_to(:destroy, Document) }
            it { is_expected.to be_able_to(:manage, Projet) }
          end

          context "il peut uniquement lire le projet et gérer les documents une fois le projet 'transmis pour instruction'" do
            let(:projet) { create :projet, :transmis_pour_instruction }

            it { is_expected.not_to be_able_to(:manage, AvisImposition) }
            it { is_expected.not_to be_able_to(:manage, Demande) }
            it { is_expected.not_to be_able_to(:manage, :demandeur) }
            it { is_expected.not_to be_able_to(:manage, :eligibility) }
            it { is_expected.not_to be_able_to(:manage, Occupant) }
            it { is_expected.not_to be_able_to(:manage, Projet) }

            it { is_expected.to be_able_to(:update, Document) }
            it { is_expected.to be_able_to(:destroy, Document) }
            it { is_expected.to be_able_to(:read, Projet) }
          end
        end
      end
 
      describe "en tant que PRIS" do
        let(:agent) { create :agent, intervenant: projet.invited_pris }

        context "avant que le demandeur ne s'engage avec l'operateur" do
          context "il peut lire le projet mais pas le modifier" do
            let(:projet) { create :projet, :prospect, :with_invited_pris }

            it { is_expected.not_to be_able_to(:read, AvisImposition) }
            it { is_expected.not_to be_able_to(:read, Demande) }
            it { is_expected.not_to be_able_to(:read, :demandeur) }
            it { is_expected.not_to be_able_to(:read, :eligibility) }
            it { is_expected.not_to be_able_to(:read, Occupant) }
            it { is_expected.to     be_able_to(:read, Projet) }
          end
        end

        context "une fois le demandeur engagé avec l'operateur" do
          context "il ne peut ni modifier ni lire le projet" do
            let(:projet) { create :projet, :en_cours, :with_invited_pris }

            it { is_expected.not_to be_able_to(:read, AvisImposition) }
            it { is_expected.not_to be_able_to(:read, Demande) }
            it { is_expected.not_to be_able_to(:read, :demandeur) }
            it { is_expected.not_to be_able_to(:read, Document) }
            it { is_expected.not_to be_able_to(:read, :eligibility) }
            it { is_expected.not_to be_able_to(:read, Occupant) }
            it { is_expected.not_to be_able_to(:read, Projet) }
          end
        end
      end

      context "en tant qu'instructeur" do
        context "avant que le projet ne soit 'transmis_pour_instruction'" do
          context "il ne peut ni lire ni modifier un projet" do
            let(:projet)      { create :projet, :prospect, :with_invited_instructeur }
            let(:instructeur) { create :instructeur }
            let(:agent)       { create :agent, intervenant: instructeur }

            it { is_expected.not_to be_able_to(:read, AvisImposition) }
            it { is_expected.not_to be_able_to(:read, Demande) }
            it { is_expected.not_to be_able_to(:read, :demandeur) }
            it { is_expected.not_to be_able_to(:read, Document) }
            it { is_expected.not_to be_able_to(:read, :eligibility) }
            it { is_expected.not_to be_able_to(:read, Occupant) }
            it { is_expected.not_to be_able_to(:read, Projet) }
          end
        end

        context "une fois le projet 'transmis_pour_instruction'" do
          context "il peut lire le projet" do
            let(:projet) { create :projet, :transmis_pour_instruction, :with_committed_instructeur }
            let(:agent)  { projet.agent_instructeur }

            it { is_expected.not_to be_able_to(:read, AvisImposition) }
            it { is_expected.not_to be_able_to(:read, Demande) }
            it { is_expected.not_to be_able_to(:read, :demandeur) }
            it { is_expected.not_to be_able_to(:update, Document) }
            it { is_expected.not_to be_able_to(:destroy, Document) }
            it { is_expected.not_to be_able_to(:manage, :eligibility) }
            it { is_expected.not_to be_able_to(:read, Occupant) }

            it { is_expected.to be_able_to(:read, Document) }
            it { is_expected.to be_able_to(:create, :dossiers_opal) }
            it { is_expected.to be_able_to(:read, Projet) }
          end
        end
      end
    end

    describe "Payments abilities" do
      context "quand un registre de paiement n'existe pas" do
        let(:projet) { create :projet, :transmis_pour_instruction }

        context "en tant qu'operateur" do
          let(:agent) { create :agent, intervenant: projet.operateur }

          context "avant que le projet ne soit 'transmis_pour_instruction'" do
            let(:projet) { create :projet, :proposition_proposee }
            it { is_expected.not_to be_able_to(:create, PaymentRegistry) }
          end

          context "une fois le projet 'transmis_pour_instruction'" do
            it { is_expected.to be_able_to(:create, PaymentRegistry) }
          end
        end

        context "en tant qu'instructeur" do
          let(:agent) { create :agent, intervenant: projet.invited_instructeur }
          it { is_expected.not_to be_able_to(:create, PaymentRegistry) }
        end
      end

      context "quand un registre de paiement existe" do
        let(:projet)                         { create :projet, :transmis_pour_instruction, :with_payment_registry }

        let(:payment_en_cours_de_montage)    { create :payment, payment_registry: projet.payment_registry, statut: :en_cours_de_montage }
        let(:payment_propose)                { create :payment, payment_registry: projet.payment_registry, statut: :propose }
        let(:payment_demande)                { create :payment, payment_registry: projet.payment_registry, statut: :demande }
        let(:payment_en_cours_d_instruction) { create :payment, payment_registry: projet.payment_registry, statut: :en_cours_d_instruction }
        let(:payment_paye)                   { create :payment, payment_registry: projet.payment_registry, statut: :paye }

        let(:payment_a_rediger)              { create :payment, payment_registry: projet.payment_registry, action: :a_rediger }
        let(:payment_a_modifier)             { create :payment, payment_registry: projet.payment_registry, action: :a_modifier }
        let(:payment_a_valider)              { create :payment, payment_registry: projet.payment_registry, action: :a_valider }
        let(:payment_a_instruire)            { create :payment, payment_registry: projet.payment_registry, action: :a_instruire }
        let(:payment_no_action)              { create :payment, payment_registry: projet.payment_registry, action: :aucune }

        context "en tant qu'agent" do
          let(:agent) { create :agent }
          it { is_expected.not_to be_able_to(:read,   PaymentRegistry) }
          it { is_expected.not_to be_able_to(:create, PaymentRegistry) }
        end

        context "en tant qu'operateur" do
          let(:agent) { create :agent, intervenant: projet.operateur }

          it { is_expected.to     be_able_to(:create,               Payment) }
          it { is_expected.to     be_able_to(:read,                 Payment) }
          it { is_expected.not_to be_able_to(:ask_for_validation,   Payment) }
          it { is_expected.not_to be_able_to(:ask_for_modification, Payment) }
          it { is_expected.not_to be_able_to(:ask_for_instruction,  Payment) }
          it { is_expected.not_to be_able_to(:send_in_opal,         Payment) }

          it { is_expected.to     be_able_to(:update, payment_a_rediger) }
          it { is_expected.to     be_able_to(:update, payment_a_modifier) }
          it { is_expected.not_to be_able_to(:update, payment_a_valider) }
          it { is_expected.not_to be_able_to(:update, payment_a_instruire) }
          it { is_expected.not_to be_able_to(:update, payment_no_action) }

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

          context "quand le statut n'est pas encore 'en_cours_d_instruction'" do
            let(:projet) { create :projet, :transmis_pour_instruction, :with_payment_registry }

            it { is_expected.not_to be_able_to(:ask_for_validation, Payment) }
          end

          context "une fois le statut 'en_cours_d_instruction'" do
            let(:projet) { create :projet, :en_cours_d_instruction, :with_payment_registry }

            it { is_expected.to     be_able_to(:ask_for_validation, payment_a_rediger) }
            it { is_expected.to     be_able_to(:ask_for_validation, payment_a_modifier) }
            it { is_expected.not_to be_able_to(:ask_for_validation, payment_a_valider) }
            it { is_expected.not_to be_able_to(:ask_for_validation, payment_a_instruire) }
            it { is_expected.not_to be_able_to(:ask_for_validation, payment_no_action) }
          end
        end

        context "en tant qu'instructeur" do
          let(:agent) { create :agent, intervenant: projet.invited_instructeur }

          it { is_expected.not_to be_able_to(:create,               Payment) }
          it { is_expected.not_to be_able_to(:update,               Payment) }
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
