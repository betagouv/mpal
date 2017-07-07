require 'rails_helper'
require 'support/mpal_helper'

describe PaymentsController do
  let(:projet) { create :projet, :transmis_pour_instruction, :with_payment_registry }
  let(:agent_operateur) { projet.agent_operateur }

  before(:each) { authenticate_as_agent agent_operateur }

  describe "#new" do
    before { get :new, dossier_id: projet.id }
    it { is_expected.to render_template :new }
  end

  describe "#create" do
    context "avec des paramètres requis non remplis" do
      it "ne crée pas de demande de paiement" do
        post :create, dossier_id: projet.id, payment: {
          beneficiaire: "Emile Lévesque",
          personne_morale: "0"
        }
        expect(Payment.all.count).to eq 0
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
end
