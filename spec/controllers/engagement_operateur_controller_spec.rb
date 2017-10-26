require "rails_helper"
require "support/mpal_helper"
require "support/rod_helper"

describe EngagementOperateurController do
  describe "#create" do
    context "si déjà engagé avec un opérateur" do
      let(:projet)     { create :projet, :en_cours }
      let(:user)       { projet.demandeur_user }
      let(:operateur)  { projet.operateur }
      let(:operateur2) { create :operateur }

      before { authenticate_as_user user }

      it "affiche une information au demandeur" do
        post :create, params: { projet_id: projet.id, operateur_id: operateur2.id }
        expect(response).to redirect_to projet_path(projet)
        expect(flash[:notice]).to be_present
      end
    end
  end
end

