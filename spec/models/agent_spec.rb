require "rails_helper"
require "cancan/matchers"
require "support/mpal_features_helper"
require "support/rod_helper"

describe Agent do
  describe "validations" do
    let(:agent) { build :agent }
    it { expect(agent).to be_valid }
    it { is_expected.to validate_presence_of :nom }
    it { is_expected.to validate_presence_of :prenom }
    it { is_expected.to belong_to :intervenant }
    it { is_expected.to have_many(:contacts) }
  end

  describe "abilities" do
    subject(:ability) { Ability.new(agent, :agent, projet) }

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

            it { is_expected.to be_able_to(:read, :intervenant) }
            it { is_expected.to be_able_to(:read, Projet) }
            it { is_expected.to be_able_to(:manage, Message) }
          end
        end

        context "quand il est engagé avec le demandeur" do
          let(:agent)     { create :agent, intervenant: projet.operateur }
          let!(:document) { create :document, category: projet, created_at: DateTime.new(2017,02,03) }

          context "il peut gérer le projet jusqu'à ce qu'il soit 'transmis pour instruction'" do
            let(:projet) { create :projet, :en_cours}

            it { is_expected.not_to be_able_to(:manage, :eligibility) }

            it { is_expected.to be_able_to(:manage, AvisImposition) }
            it { is_expected.to be_able_to(:read, :intervenant) }
            it { is_expected.to be_able_to(:manage, Demande) }
            it { is_expected.to be_able_to(:manage, :demandeur) }
            it { is_expected.to be_able_to(:manage, Occupant) }
            it { is_expected.to be_able_to(:destroy, document) }
            it { is_expected.to be_able_to(:manage, Projet) }
          end

          context "il peut uniquement lire le projet et gérer les documents une fois le projet 'transmis pour instruction'" do
            let(:projet) { create :projet, :transmis_pour_instruction, date_depot: DateTime.new(2017,02,04) }

            it { is_expected.not_to be_able_to(:manage, AvisImposition) }
            it { is_expected.not_to be_able_to(:manage, Demande) }
            it { is_expected.not_to be_able_to(:manage, :demandeur) }
            it { is_expected.not_to be_able_to(:manage, :eligibility) }
            it { is_expected.not_to be_able_to(:manage, Occupant) }
            it { is_expected.not_to be_able_to(:manage, Projet) }

            it { is_expected.not_to be_able_to(:destroy, document) }
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

            it { is_expected.to be_able_to(:read, :intervenant) }
            it { is_expected.to be_able_to(:read, Projet) }
          end
        end

        context "une fois le demandeur engagé avec l'operateur" do
          context "il ne peut ni modifier ni lire le projet" do
            let(:projet) { create :projet, :en_cours }

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
            it { is_expected.not_to be_able_to(:destroy, Document) }
            it { is_expected.not_to be_able_to(:manage, :eligibility) }
            it { is_expected.not_to be_able_to(:read, Occupant) }

            it { is_expected.to be_able_to(:read, :intervenant) }
            it { is_expected.to be_able_to(:read, Document) }
            it { is_expected.to be_able_to(:create, :dossiers_opal) }
            it { is_expected.to be_able_to(:read, Projet) }
          end
        end
      end
    end

    describe "Payments abilities" do
      let(:projet)                         { create :projet, :transmis_pour_instruction }

      let(:payment_en_cours_de_montage)    { create :payment, projet: projet, statut: :en_cours_de_montage }
      let(:payment_propose)                { create :payment, projet: projet, statut: :propose }
      let(:payment_demande)                { create :payment, projet: projet, statut: :demande }
      let(:payment_en_cours_d_instruction) { create :payment, projet: projet, statut: :en_cours_d_instruction }
      let(:payment_paye)                   { create :payment, projet: projet, statut: :paye }

      let(:payment_a_rediger)              { create :payment, projet: projet, action: :a_rediger }
      let(:payment_a_modifier)             { create :payment, projet: projet, action: :a_modifier }
      let(:payment_a_valider)              { create :payment, projet: projet, action: :a_valider }
      let(:payment_a_instruire)            { create :payment, projet: projet, action: :a_instruire }
      let(:payment_no_action)              { create :payment, projet: projet, action: :aucune }

      context "en tant qu'agent" do
        let(:agent)     { create :agent }
        let!(:document) { create :document, category: payment_a_rediger }

        it { is_expected.not_to be_able_to(:read,    document) }
        it { is_expected.not_to be_able_to(:destroy, document) }
      end

      context "en tant qu'operateur" do
        let(:agent)     { create :agent, intervenant: projet.operateur }
        let!(:document) { create :document, category: payment_a_rediger }

        it { is_expected.to     be_able_to(:read,    document) }
        it { is_expected.to     be_able_to(:destroy, document) }
        # tester les droits de suppression sur les documents des paiements

        it { is_expected.to     be_able_to(:create,               Payment) } #?
        it { is_expected.to     be_able_to(:read,                 Payment) } #?
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
          let(:projet) { create :projet, :transmis_pour_instruction }

          it { is_expected.not_to be_able_to(:ask_for_validation, Payment) }
        end

        context "une fois le statut 'en_cours_d_instruction'" do
          let(:projet) { create :projet, :en_cours_d_instruction }

          it { is_expected.to     be_able_to(:ask_for_validation, payment_a_rediger) }
          it { is_expected.to     be_able_to(:ask_for_validation, payment_a_modifier) }
          it { is_expected.not_to be_able_to(:ask_for_validation, payment_a_valider) }
          it { is_expected.not_to be_able_to(:ask_for_validation, payment_a_instruire) }
          it { is_expected.not_to be_able_to(:ask_for_validation, payment_no_action) }
        end
      end

      context "en tant qu'instructeur" do
        let(:agent)     { create :agent, intervenant: projet.invited_instructeur }
        let!(:document) { create :document, category: payment_a_rediger }

        it { is_expected.to     be_able_to(:read,    document) }
        it { is_expected.not_to be_able_to(:destroy, document) }

        it { is_expected.to     be_able_to(:index,               Payment) }
        it { is_expected.not_to be_able_to(:create,              Payment) }
        it { is_expected.not_to be_able_to(:update,              Payment) }
        it { is_expected.not_to be_able_to(:destroy,             Payment) }
        it { is_expected.not_to be_able_to(:ask_for_validation,  Payment) }
        it { is_expected.not_to be_able_to(:ask_for_instruction, Payment) }

        it { is_expected.not_to be_able_to(:show, payment_en_cours_de_montage) }
        it { is_expected.not_to be_able_to(:show, payment_propose) }
        it { is_expected.to     be_able_to(:show, payment_demande) }
        it { is_expected.to     be_able_to(:show, payment_en_cours_d_instruction) }
        it { is_expected.to     be_able_to(:show, payment_paye) }

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

  describe "#cas_extra_attributes=" do
    let(:prenom) { "Jean" }
    let(:nom) { "Durand" }
    let(:agent) { build :agent }
    before { Fakeweb::Rod.register_intervenant }
    before { agent.cas_extra_attributes = { Prenom: prenom, Nom: nom, ServiceId: clavis_service_id } }

    context "si l’agent n’existe pas" do
      let(:clavis_service_id) { "4321" }
      it { expect(agent.prenom).to eq(prenom) }
      it { expect(agent.nom).to eq(nom) }
      it { expect(agent.intervenant.clavis_service_id).to eq(clavis_service_id) }
    end

    context "si l’intervenant n’existe pas" do
      let(:clavis_service_id) { "1234" }
      it { expect(agent.intervenant.clavis_service_id).to eq(clavis_service_id) }
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

