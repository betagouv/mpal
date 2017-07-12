require 'rails_helper'
require 'support/api_particulier_helper'
require 'support/mpal_helper'

describe AvisImpositionsController do
  let(:projet) { create :projet }

  before(:each) { authenticate(projet.id) }

  describe "#new" do
    it "affiche le formulaire d'ajout d'un avis" do
      get :new, projet_id: projet.id
      expect(response).to render_template('new')
    end
  end
  
  describe "#create" do
    let(:projet)     { create :projet, :with_avis_imposition }
    let(:first_avis) { projet.avis_impositions.first }

    context "quand le numéro et la référence sont valides" do
      let(:numero_fiscal)   { Fakeweb::ApiParticulier::NUMERO_FISCAL_NON_ELIGIBLE }
      let(:reference_avis)  { Fakeweb::ApiParticulier::REFERENCE_AVIS_NON_ELIGIBLE }

      it "ajoute un avis d'imposition au projet" do
        post :create, projet_id: projet.id,
        avis_imposition: { numero_fiscal: numero_fiscal, reference_avis: reference_avis }
        projet.reload
        expect(projet.avis_impositions.count).to eq 2
        expect(projet.avis_impositions.first).to eq first_avis
        expect(projet.avis_impositions.last).to be_valid
        expect(projet.avis_impositions.last.numero_fiscal).to eq '13'
        expect(projet.avis_impositions.last.reference_avis).to eq '16'

        expect(flash[:notice]).to be_present
        expect(response).to redirect_to projet_avis_impositions_path(projet)
      end
    end

    context "quand l'année de revenus n'est pas valide" do
      let(:numero_fiscal)  { Fakeweb::ApiParticulier::NUMERO_FISCAL_ANNEE_INVALIDE }
      let(:reference_avis) { Fakeweb::ApiParticulier::REFERENCE_AVIS_ANNEE_INVALIDE }

      it "il obtient un message d'erreur" do
        post :create, projet_id: projet.id,
        avis_imposition: { numero_fiscal: numero_fiscal, reference_avis: reference_avis }
        expect(response).to redirect_to new_projet_avis_imposition_path projet
        expect(flash[:alert]).to be_present
      end
    end

    context "quand le numéro et la référence sont invalides" do
      let(:numero_fiscal)   { Fakeweb::ApiParticulier::INVALID }
      let(:reference_avis)  { Fakeweb::ApiParticulier::INVALID}

      it "n'ajoute pas un avis d'imposition au projet" do
        post :create, projet_id: projet.id,
        avis_imposition: { numero_fiscal: numero_fiscal, reference_avis: reference_avis }
        projet.reload
        expect(projet.avis_impositions.count).to eq 1
        expect(projet.avis_impositions.first).to eq first_avis

        expect(flash[:alert]).to be_present
        expect(response).to redirect_to new_projet_avis_imposition_path(projet)
      end
    end
  end

  describe "#update_project_rfr" do
    let!(:projet) { create :projet, :en_cours }

    before(:each) { authenticate_as_agent projet.agent_operateur }

    context "si le modified_RFR est mal ou n'est pas complété" do
      it "le modified RFR est nul" do
        put :update_project_rfr, dossier_id: projet.id, projet: { modified_revenu_fiscal_reference: "abc" }
        expect(projet.reload.modified_revenu_fiscal_reference).to be_nil
      end
    end

    context "si le modified_RFR est rempli" do
      it "modifie le modified_rfr" do
        put :update_project_rfr, dossier_id: projet.id, projet: { modified_revenu_fiscal_reference: "123" }
        expect(projet.reload.modified_revenu_fiscal_reference).to eq 123
        put :update_project_rfr, dossier_id: projet.id, projet: { modified_revenu_fiscal_reference: "111" }
        expect(projet.reload.modified_revenu_fiscal_reference).to eq 111
      end
    end
  end

  describe "#destroy" do
    let(:projet)      { create :projet, :with_avis_imposition }
    let(:first_avis)  { projet.avis_impositions.first }

    it "ne supprime pas le premier avis d'imposition" do
      delete :destroy, projet_id: projet.id, id: first_avis.id
      projet.reload
      expect(projet.avis_impositions.count).to eq 1
    end

    context "quand il y a plusieurs avis d'imposition" do
      let(:numero_fiscal)  { Fakeweb::ApiParticulier::NUMERO_FISCAL_NON_ELIGIBLE }
      let(:reference_avis) { Fakeweb::ApiParticulier::REFERENCE_AVIS_NON_ELIGIBLE }
      let(:projet)         { create :projet, :with_avis_imposition }
      let(:first_avis)     { projet.avis_impositions.first }
      let(:last_avis)      { create :avis_imposition, numero_fiscal: numero_fiscal, reference_avis: reference_avis }

      before { projet.avis_impositions << last_avis }

      it "ne supprime pas le premier avis d'imposition" do
        delete :destroy, projet_id: projet.id, id: first_avis.id
        projet.reload
        expect(projet.avis_impositions.count).to eq 2
      end

      it "supprime un avis d'imposition rajouté" do
        delete :destroy, projet_id: projet.id, id: last_avis.id
        projet.reload
        expect(flash[:notice]).to be_present
        expect(projet.avis_impositions.count).to eq 1
      end
    end
  end
end
