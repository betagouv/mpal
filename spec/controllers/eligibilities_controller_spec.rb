require "rails_helper"
require "support/api_particulier_helper"
require "support/api_ban_helper"
require "support/mpal_helper"
require "support/rod_helper"

describe EligibilitiesController do
  describe "#show" do
    let(:projet) { create :projet, :prospect }

    before { authenticate_as_project projet.id }

    it "met à jour le locked_at" do
      get :show, params: { projet_id: projet.id }
      expect(projet.reload.locked_at).to eq Time.now
    end

    context "pour un projet éligible" do
      it "renvoie le PRIS" do
        get :show, params: { projet_id: projet.id }
        expect(assigns(:pris).raison_sociale).to eq "ADIL du Doubs"
      end
    end

    context "pour un projet non éligible" do
      before { projet.avis_impositions.first.update(revenu_fiscal_reference: 1000000) }

      it "renvoie le PRIS EIE" do
        get :show, params: { projet_id: projet.id }
        expect(assigns(:pris).raison_sociale).to eq "ADIL Doudoux"
      end
    end
  end
end
