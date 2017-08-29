require 'rails_helper'
require 'support/mpal_helper'

describe PaymentRegistriesController do
  let(:agent_operateur) { projet.agent_operateur }

  describe "#show" do
    let(:projet)             { create :projet, :transmis_pour_instruction, :with_payment_registry }
    let(:payment_en_montage) { create :payment, statut: :en_cours_de_montage }
    let(:payment_demande)    { create :payment, statut: :demande }
    let(:user)               { projet.user }


    before do
      projet.payment_registry.payments << payment_en_montage
      projet.payment_registry.payments << payment_demande
    end

    context "en tant que demandeur" do
      before { authenticate_as_user(user) }

      it "affiche le registre de paiement" do
        get :show, projet_id: projet.id
        payments = assigns[:payments]
        expect(response).to render_template :show
        expect(payments).not_to include payment_en_montage
        expect(payments).to     include payment_demande
      end
    end

    context "en tant qu'agent opérateur" do
      before { authenticate_as_agent agent_operateur }

      it "affiche le registre de paiement" do
        get :show, dossier_id: projet.id
        payments = assigns[:payments]
        expect(response).to render_template :show
        expect(payments).to include payment_en_montage
        expect(payments).to include payment_demande
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
