require 'rails_helper'
require 'support/api_particulier_helper'
require 'support/api_ban_helper'

describe ProjetsController do
  describe "#create" do

    # context "quand le demandeur n’est pas propriétaire" do
    #   let(:numero_fiscal)  { Fakeweb::ApiParticulier::NUMERO_FISCAL }
    #   let(:reference_avis) { Fakeweb::ApiParticulier::REFERENCE_AVIS }
    #   let(:projet)         { Projet.last }
    #
    #   it "il obtient un message d’erreur" do
    #     post :create, numero_fiscal: numero_fiscal, reference_avis: reference_avis, proprietaire: "0"
    #     expect(response).to render_template("new")
    #     expect(flash[:alert]).to be_present
    #   end
    # end

  end
end
