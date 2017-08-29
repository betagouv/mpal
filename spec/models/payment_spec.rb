require "rails_helper"
require "support/state_machines_helper"

describe Payment do
  describe "validations" do
    let(:payment) { build :payment }
    it { expect(payment).to be_valid }
    it { is_expected.to validate_presence_of :beneficiaire }
    it { is_expected.to validate_presence_of :type_paiement }
    it { is_expected.to belong_to :payment_registry }
  end

  describe "#description" do
    let(:payment_avance)  { create :payment, type_paiement: :avance }
    let(:payment_acompte) { create :payment, type_paiement: :acompte }
    let(:payment_solde)   { create :payment, type_paiement: :solde }

    it { expect(payment_avance.description).to  eq "Demande d’avance" }
    it { expect(payment_acompte.description).to eq "Demande d’acompte" }
    it { expect(payment_solde.description).to   eq "Demande de solde" }
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

    it { expect(payment_en_cours_de_montage.status_with_action).to    eq "En cours de montage" }
    it { expect(payment_propose.status_with_action).to                eq "Proposée en attente de validation" }
    it { expect(payment_propose_a_modifier.status_with_action).to     eq "Proposée en attente de modification" }
    it { expect(payment_demande.status_with_action).to                eq "Déposée en attente d’instruction" }
    it { expect(payment_demande_a_modifier.status_with_action).to     eq "Déposée en attente de modification" }
    it { expect(payment_demande_a_valider.status_with_action).to      eq "Déposée en attente de validation" }
    it { expect(payment_en_cours_d_instruction.status_with_action).to eq "En cours d’instruction" }
    it { expect(payment_paye.status_with_action).to                   eq "Payée" }
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
    end
  end
end
