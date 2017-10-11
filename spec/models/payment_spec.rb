require "rails_helper"
require "support/state_machines_helper"

describe Payment do
  describe "validations" do
    let(:payment) { build :payment }
    it { expect(payment).to be_valid }
    it { is_expected.to validate_presence_of :beneficiaire }
    it { is_expected.to validate_presence_of :type_paiement }
    it { is_expected.to belong_to :projet }
    it { is_expected.to have_many :documents }
  end

  describe "#validate_projet" do
    let!(:projet_prospect)                   { create :projet, :prospect }
    let!(:projet_en_cours)                   { create :projet, :en_cours }
    let!(:projet_proposition_enregistree)    { create :projet, :proposition_enregistree }
    let!(:projet_proposition_proposee)       { create :projet, :proposition_proposee }
    let!(:projet_transmis_pour_instruction)  { create :projet, :transmis_pour_instruction }
    let!(:projet_en_cours_d_instruction)     { create :projet, :en_cours_d_instruction }

    let(:payment_prospect)                   { build :payment, projet: projet_prospect }
    let(:payment_en_cours)                   { build :payment, projet: projet_en_cours }
    let(:payment_proposition_enregistree)    { build :payment, projet: projet_proposition_enregistree }
    let(:payment_proposition_proposee)       { build :payment, projet: projet_proposition_proposee }
    let(:payment_transmis_pour_instruction)  { build :payment, projet: projet_transmis_pour_instruction }
    let(:payment_en_cours_d_instruction)     { build :payment, projet: projet_en_cours_d_instruction }

    it "empêche de créer une demande de paiement si le projet n'a pas été transmis pour instruction" do
      expect(payment_prospect.valid?).to                  be_falsy
      expect(payment_en_cours.valid?).to                  be_falsy
      expect(payment_proposition_enregistree.valid?).to   be_falsy
      expect(payment_proposition_proposee.valid?).to      be_falsy
      expect(payment_transmis_pour_instruction.valid?).to be_truthy
      expect(payment_en_cours_d_instruction.valid?).to    be_truthy
    end
  end

  describe "#description" do
    let(:payment_avance)  { create :payment, type_paiement: :avance }
    let(:payment_acompte) { create :payment, type_paiement: :acompte }
    let(:payment_solde)   { create :payment, type_paiement: :solde }

    it do
      expect(payment_avance.description).to  eq "Demande d’avance"
      expect(payment_acompte.description).to eq "Demande d’acompte"
      expect(payment_solde.description).to   eq "Demande de solde"
    end
  end

  describe "#status_with_action" do
    let(:payment_en_cours_de_montage)    { create :payment, statut: :en_cours_de_montage }
    let(:payment_propose)                { create :payment, statut: :propose,                action: :a_valider }
    let(:payment_propose_a_modifier)     { create :payment, statut: :propose,                action: :a_modifier }
    let(:payment_demande)                { create :payment, statut: :demande,                action: :a_instruire }
    let(:payment_demande_a_modifier)     { create :payment, statut: :demande,                action: :a_modifier }
    let(:payment_demande_a_valider)      { create :payment, statut: :demande,                action: :a_valider }
    let(:payment_en_cours_d_instruction) { create :payment, statut: :en_cours_d_instruction, action: :aucune }
    let(:payment_paye)                   { create :payment, statut: :paye,                   action: :aucune }

    it do
      expect(payment_en_cours_de_montage.status_with_action).to    eq "En cours de montage"
      expect(payment_propose.status_with_action).to                eq "Proposée en attente de validation"
      expect(payment_propose_a_modifier.status_with_action).to     eq "Proposée en attente de modification"
      expect(payment_demande.status_with_action).to                eq "Déposée en attente d’instruction"
      expect(payment_demande_a_modifier.status_with_action).to     eq "Déposée en attente de modification"
      expect(payment_demande_a_valider.status_with_action).to      eq "Déposée en attente de validation"
      expect(payment_en_cours_d_instruction.status_with_action).to eq "En cours d’instruction"
      expect(payment_paye.status_with_action).to                   eq "Payée"
    end
  end

  describe "#dashboard_status" do
    let(:payment_avance)                 { create :payment, type_paiement: :avance }
    let(:payment_acompte)                { create :payment, type_paiement: :acompte }
    let(:payment_solde)                  { create :payment, type_paiement: :solde }
    let(:payment_en_cours_de_montage)    { create :payment, statut: :en_cours_de_montage }
    let(:payment_propose)                { create :payment, statut: :propose }
    let(:payment_demande)                { create :payment, statut: :demande }
    let(:payment_en_cours_d_instruction) { create :payment, statut: :en_cours_d_instruction }
    let(:payment_paye)                   { create :payment, statut: :paye }

    it do
      expect(payment_avance.dashboard_status).to                 include I18n.t("payment.type_paiement.avance")
      expect(payment_acompte.dashboard_status).to                include I18n.t("payment.type_paiement.acompte")
      expect(payment_solde.dashboard_status).to                  include I18n.t("payment.type_paiement.solde")
      expect(payment_en_cours_de_montage.dashboard_status).to    include I18n.t("payment.statut.en_cours_de_montage")
      expect(payment_propose.dashboard_status).to                include I18n.t("payment.statut.propose")
      expect(payment_demande.dashboard_status).to                include I18n.t("payment.statut.demande")
      expect(payment_en_cours_d_instruction.dashboard_status).to include I18n.t("payment.statut.en_cours_d_instruction")
      expect(payment_paye.dashboard_status).to                   include I18n.t("payment.statut.paye")
    end
  end

  describe "#statut" do
    describe "en_cours_de_montage" do
      let(:payment) { create :payment }

      it { should_have(:statut).equal_to(:en_cours_de_montage) }
      it { should_have(:statut).equal_to(:propose).after_event(:ask_for_validation) }
      it { should_have(:statut).equal_to(:propose).after_event(:ask_for_modification) }
      it { should_have(:statut).equal_to(:en_cours_de_montage).after_event(:ask_for_instruction) }
      it { should_have(:statut).equal_to(:en_cours_de_montage).after_event(:send_in_opal) }
    end

    describe "propose" do
      let(:payment) { create :payment, :propose }
      let(:submit_time) { Time.now }

      it { should_have(:statut).equal_to(:propose).after_event(:ask_for_validation) }
      it { should_have(:statut).equal_to(:propose).after_event(:ask_for_modification) }
      it { should_have(:statut).equal_to(:demande).after_event(:ask_for_instruction) }
      it { should_have(:submitted_at).equal_to(submit_time).after_event(:ask_for_instruction) }
      it { should_have(:statut).equal_to(:propose).after_event(:send_in_opal) }
    end

    describe "demande" do
      let(:payment) { create :payment, :demande }

      it { should_have(:statut).equal_to(:demande).after_event(:ask_for_validation) }
      it { should_have(:statut).equal_to(:demande).after_event(:ask_for_modification) }
      it { should_have(:statut).equal_to(:demande).after_event(:ask_for_instruction) }
      it { should_have(:statut).equal_to(:en_cours_d_instruction).after_event(:send_in_opal) }
    end

    describe "en_cours_d_instruction" do
      let(:payment) { create :payment, :en_cours_d_instruction }

      it { should_have(:statut).equal_to(:en_cours_d_instruction).after_event(:ask_for_validation) }
      it { should_have(:statut).equal_to(:en_cours_d_instruction).after_event(:ask_for_modification) }
      it { should_have(:statut).equal_to(:en_cours_d_instruction).after_event(:ask_for_instruction) }
      it { should_have(:statut).equal_to(:en_cours_d_instruction).after_event(:send_in_opal) }
    end
  end

  describe "#action" do
    describe "a_rediger" do
      let(:payment) { create :payment }

      it { should_have(:action).equal_to(:a_rediger) }
      it { should_have(:action).equal_to(:a_valider).after_event(:ask_for_validation) }
      it { should_have(:action).equal_to(:a_rediger).after_event(:ask_for_modification) }
      it { should_have(:action).equal_to(:a_rediger).after_event(:ask_for_instruction) }
      it { should_have(:action).equal_to(:a_rediger).after_event(:send_in_opal) }
    end

    describe "a_valider" do
      let(:payment) { create :payment, :propose }

      it { should_have(:action).equal_to(:a_valider).after_event(:ask_for_validation) }
      it { should_have(:action).equal_to(:a_modifier).after_event(:ask_for_modification) }
      it { should_have(:action).equal_to(:a_instruire).after_event(:ask_for_instruction) }
      it { should_have(:action).equal_to(:a_valider).after_event(:send_in_opal) }
    end

    describe "a_modifier" do
      let(:payment) { create :payment, :demande, :a_modifier }

      it { should_have(:action).equal_to(:a_valider).after_event(:ask_for_validation) }
      it { should_have(:action).equal_to(:a_modifier).after_event(:ask_for_modification) }
      it { should_have(:action).equal_to(:a_modifier).after_event(:ask_for_instruction) }
      it { should_have(:action).equal_to(:a_modifier).after_event(:send_in_opal) }
    end

    describe "a_instruire" do
      let(:payment) { create :payment, :demande }

      it { should_have(:action).equal_to(:a_instruire).after_event(:ask_for_validation) }
      it { should_have(:action).equal_to(:a_modifier).after_event(:ask_for_modification) }
      it { should_have(:action).equal_to(:a_instruire).after_event(:ask_for_instruction) }
      it { should_have(:action).equal_to(:aucune).after_event(:send_in_opal) }

      context "quand la demande de paiement n'a pas encore été déposée" do
        it { should_have(:corrected_at).equal_to(nil).after_event(:ask_for_instruction) }
      end

      context "quand la demande de paiement a déjà été déposée" do
        let(:correction_time) { Time.new(2017,2,1) }

        before do
          payment.update! action: :a_valider, submitted_at: Time.new(2017)
          allow(Time).to receive(:now).and_return(correction_time)
        end

        it { should_have(:corrected_at).equal_to(correction_time).after_event(:ask_for_instruction) }
      end
    end
  end
end
