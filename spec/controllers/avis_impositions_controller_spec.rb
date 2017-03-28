require 'rails_helper'
require 'support/api_particulier_helper'
require 'support/mpal_helper'

describe AvisImpositionsController do
  let(:projet) { create :projet }

  before(:each) do
    authenticate_as_particulier(projet.numero_fiscal)
  end

  describe "#new" do
    it "affiche le formulaire d'ajout d'un avis" do
      get :new, projet_id: projet.id
      expect(response).to render_template('new')
    end
  end

  describe "#create" do
    let(:projet)          { create :projet, :with_avis_imposition }
    let(:first_avis)      { projet.avis_impositions.first }

    context "quand le numéro et la référence sont valides" do
      let(:numero_fiscal)   { Fakeweb::ApiParticulier::NUMERO_FISCAL_NON_ELIGIBLE }
      let(:reference_avis)  { Fakeweb::ApiParticulier::REFERENCE_AVIS_NON_ELIGIBLE }

      it "ajoute un avis d'imposition au projet" do
        get :create, projet_id: projet.id,
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

    context "quand le numéro et la référence sont invalides" do
      let(:numero_fiscal)   { Fakeweb::ApiParticulier::INVALID }
      let(:reference_avis)  { Fakeweb::ApiParticulier::INVALID}

      it "n'ajoute pas un avis d'imposition au projet" do
        skip "TODO"
        get :create, projet_id: projet.id,
            avis_imposition: { numero_fiscal: numero_fiscal, reference_avis: reference_avis }
        projet.reload
        expect(projet.avis_impositions.count).to eq 1
        expect(projet.avis_impositions.first).to eq first_avis

        expect(flash[:alert]).to be_present
        expect(response).to redirect_to projet_avis_impositions_path(projet)
      end
    end
  end
end
