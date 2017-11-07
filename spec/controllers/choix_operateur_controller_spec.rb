require "rails_helper"
require "support/mpal_helper"
require "support/rod_helper"

describe ChoixOperateurController do
  let(:projet) { create :projet, :prospect, :with_account, :with_intervenants_disponibles }
  let(:user)   { projet.demandeur_user }

  before(:each) { authenticate_as_user user }

  describe "#new" do
    it "affiche les opérateurs disponibles" do
      get :new, params: { projet_id: projet.id }
      expect(response).to render_template('new')
    end
  end

  describe "#choose" do

    context "quand le demandeur n'est pas engagé avec un opérateur" do
      let(:operateur) { Intervenant.pour_role(:operateur).first }

      it "invite un opérateur sur le projet" do
        patch :choose, params: {
          projet_id: projet.id,
          operateur_id: operateur.id,
          projet: { disponibilite: 'Plutôt le midi' }
        }
        projet.reload
        expect(projet.contacted_operateur).to eq operateur
        expect(projet.disponibilite).to eq 'Plutôt le midi'
        expect(response).to redirect_to projet_path(projet)
      end
    end

    context "quand le demandeur est déjà engagé avec un opérateur" do
      let(:projet_committed)      { create :projet, :en_cours, :with_committed_operateur }
      let(:user_projet_committed) { projet_committed.demandeur_user }

      before { authenticate_as_user user_projet_committed }

      it "redirige sur la page projet" do
        get :new, params: { projet_id: projet_committed.id }
        expect(response).to redirect_to root_path
        expect(flash[:alert]).to be_present
      end
    end
  end
end
