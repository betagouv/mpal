require 'rails_helper'
require 'support/mpal_helper'

describe PaymentsController do
  let(:projet) { create :projet, :transmis_pour_instruction, :with_payment_registry }
  let(:agent_operateur) { projet.agent_operateur }

  describe "#new" do
    before do
      authenticate_as_agent agent_operateur
      get :new, dossier_id: projet.id
    end
    it { is_expected.to render_template :new }
  end

  describe "#create" do
    before(:each) { authenticate_as_agent agent_operateur }

    context "avec des paramètres requis non remplis" do
      it "ne crée pas de demande de paiement" do
        post :create, dossier_id: projet.id, payment: {
          beneficiaire: "Emile Lévesque",
          personne_morale: "0"
        }
        expect(Payment.all.count).to eq 0
        expect(response).to render_template :new
      end
    end

    context "avec tous les paramètres requis" do
      it "crée une demande de paiement" do
        post :create, dossier_id: projet.id, payment: {
          type_paiement: "avance",
          beneficiaire: "SOLIHA",
          personne_morale: "1"
        }
        projet.reload
        payment = projet.payment_registry.payments.first
        expect(Payment.all.count).to eq 1
        expect(payment.type_paiement).to eq "avance"
        expect(payment.beneficiaire).to eq "SOLIHA"
        expect(payment.personne_morale).to eq true
        expect(response).to redirect_to dossier_payment_registry_path(projet)
      end
    end
  end

  context "avec une demande de paiement" do
    let(:payment) { create :payment, beneficiaire: "Emile Lévesque", payment_registry: projet.payment_registry }

    describe "#edit" do
      before do
        authenticate_as_agent agent_operateur
        get :edit, dossier_id: projet.id, payment_id: payment.id
      end
      it { is_expected.to render_template :edit }
    end

    describe "#update" do
      before(:each) { authenticate_as_agent agent_operateur }

      context "avec des paramètres requis non remplis" do
        it "ne modifie pas la demande de paiement" do
          put :update, dossier_id: projet.id, payment_id: payment.id, payment: {
            type_paiement: "solde",
            personne_morale: "1"
          }
          payment.reload
          expect(Payment.all.count).to       eq 1
          expect(payment.type_paiement).to   eq "avance"
          expect(payment.beneficiaire).to    eq "Emile Lévesque"
          expect(payment.personne_morale).to eq false
          expect(response).to render_template :edit
        end
      end

      context "avec tous les paramètres requis" do
        it "modifie la demande de paiement" do
          put :update, dossier_id: projet.id, payment_id: payment.id, payment: {
            type_paiement: "solde",
            beneficiaire: "SOLIHA",
            personne_morale: "1"
          }
          payment.reload
          expect(Payment.all.count).to       eq 1
          expect(payment.type_paiement).to   eq "solde"
          expect(payment.beneficiaire).to    eq "SOLIHA"
          expect(payment.personne_morale).to eq true
          expect(response).to redirect_to dossier_payment_registry_path(projet)
        end
      end
    end

    describe "#destroy" do
      before(:each) { authenticate_as_agent agent_operateur }

      it "supprime la demande de paiement" do
        delete :destroy, dossier_id: projet.id, payment_id: payment.id
        expect(Payment.all.count).to eq 0
        expect(response).to redirect_to dossier_payment_registry_path(projet)
      end

      context "si une erreur survient lors de la suppression" do
        it "affiche un message d'erreur" do
          delete :destroy, dossier_id: projet.id, payment_id: (payment.id + 1)
          expect(response).to redirect_to "/404"
        end
      end
    end

    describe "#ask_for_validation" do
      let(:projet) { create :projet, :en_cours_d_instruction, :with_payment_registry }

      before { authenticate_as_agent agent_operateur }

      it "passe la demande en proposé au demandeur pour validation" do
        put :ask_for_validation, dossier_id: projet.id, payment_id: payment.id
        payment.reload
        expect(payment.action).to eq "a_valider"
        expect(payment.statut).to eq "propose"
        expect(response).to redirect_to dossier_payment_registry_path(projet)
      end
    end

    describe "#ask_for_modification" do
      let(:projet)  { create :projet, :en_cours_d_instruction, :with_payment_registry }
      let(:payment) { create :payment, statut: "propose", action: "a_valider", beneficiaire: "Emile Lévesque", payment_registry: projet.payment_registry }

      before { authenticate_as_project projet.id }

      it "passe la demande a l'opérateur pour modification" do
        put :ask_for_modification, projet_id: projet.id, payment_id: payment.id
        payment.reload
        expect(payment.action).to eq "a_modifier"
        expect(payment.statut).to eq "propose"
        expect(response).to redirect_to projet_payment_registry_path(projet)
      end
    end

    describe "#ask_for_instruction" do
      let(:projet)      { create :projet, :en_cours_d_instruction, :with_payment_registry }
      let(:payment)     { create :payment, statut: "propose", action: "a_valider", beneficiaire: "Emile Lévesque", payment_registry: projet.payment_registry }
      let(:submit_time) { Time.now }

      before { authenticate_as_project projet.id }

      it "passe la demande a l'opérateur pour modification" do
        put :ask_for_instruction, projet_id: projet.id, payment_id: payment.id
        payment.reload
        expect(payment.action).to eq "a_instruire"
        expect(payment.statut).to eq "demande"
        expect(payment.submitted_at).to eq submit_time
        expect(response).to redirect_to projet_payment_registry_path(projet)
      end
    end
  end
end
