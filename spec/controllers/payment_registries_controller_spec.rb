require 'rails_helper'
require 'support/mpal_helper'

describe PaymentRegistriesController do
  let(:agent_operateur) { projet.agent_operateur }

  describe "#show" do
    let(:projet) { create :projet, :transmis_pour_instruction, :with_payment_registry }

    context "en tant que demandeur" do
      before { authenticate_as_project projet.id }

      it "affiche le registre de paiement" do
        get :show, projet_id: projet.id
        expect(response).to render_template :show
      end
    end

    context "en tant qu'agent opérateur" do
      before { authenticate_as_agent agent_operateur }

      it "affiche le registre de paiement" do
        get :show, dossier_id: projet.id
        expect(response).to render_template :show
      end
    end
  end

  describe "#create" do
    before(:each) { authenticate_as_agent agent_operateur }

    context "si le projet n'a pas encore été transmis pour instruction" do
      let(:projet) { create :projet, :proposition_proposee }

      it "affiche une erreur" do
        post :create, dossier_id: projet.id
        expect(flash[:alert]).to be_present
        expect(PaymentRegistry.all.count).to eq 0
      end
    end

    context "si le registre de paiement n'existe pas" do
      let(:projet) { create :projet, :transmis_pour_instruction }

      it "crée un registre et redirige vers celui-ci" do
        post :create, dossier_id: projet.id
        projet.reload
        expect(projet.payment_registry).to be_present
        expect(response).to redirect_to dossier_payment_registry_path(projet)
      end
    end

    context "si le registre de paiement existe déjà" do
      let(:projet)            { create :projet, :transmis_pour_instruction, :with_payment_registry }
      let!(:payment_registry) { projet.payment_registry }

      it "redirige vers le registre" do
        post :create, dossier_id: projet.id
        projet.reload
        expect(flash[:alert]).to be_present
        expect(PaymentRegistry.all.count).to eq 1
        expect(projet.payment_registry).to eq payment_registry
      end
    end
  end
end
