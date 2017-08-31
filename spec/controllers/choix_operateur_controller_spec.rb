require "rails_helper"
require "support/mpal_helper"
require "support/rod_helper"

describe ChoixOperateurController do
  let(:projet) { create :projet, :prospect }

  before(:each) { authenticate_as_project(projet.id) }

  describe "#new" do
    it "affiche les opérateurs disponibles" do
      get :new, params: { projet_id: projet.id }
      expect(response).to render_template('new')
    end
  end

  describe "#choose" do
    let(:projet)    { create :projet, :prospect, :with_intervenants_disponibles }
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

    context "quand le demandeur est déjà engagé avec un opérateur" do
      let(:projet)    { create :projet, :prospect, :with_committed_operateur }
      let(:operateur) { create :operateur }

      it "affiche une erreur" do
        patch :choose, params: {
          projet_id: projet.id,
          operateur_id: operateur.id,
          projet: { disponibilite: 'Plutôt le midi' }
        }
        expect(response).to redirect_to projet_choix_operateur_path(projet)
        expect(flash[:alert]).to be_present
      end
    end
  end
end
