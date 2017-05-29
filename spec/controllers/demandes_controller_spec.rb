require 'rails_helper'
require 'support/mpal_helper'
require 'support/api_ban_helper'

describe DemandesController do
  let(:projet) { create :projet, :prospect, demande: nil }

  before(:each) do
    authenticate_as_user(projet.id)
  end

  describe "#show" do
    before do
      get :show, projet_id: projet.id
    end

    it "renders the template" do
      expect(response).to render_template(:show)
      expect(assigns(:page_heading)).to eq 'Inscription'
    end
  end

  describe "#update" do
    context "quand les paramètres sont valides" do
      it "met à jour la demande" do
        patch :update, {
          projet_id: projet.id,
          demande: {
            changement_chauffage: '1'
          }
        }
        projet.demande.reload
        expect(projet.demande.changement_chauffage).to be true
        expect(response).to redirect_to new_user_registration_path
        expect(flash[:alert]).to be_blank
      end
    end

    context "quand aucun besoin n'est sélectionné" do
      it "affiche une erreur" do
        patch :update, {
          projet_id: projet.id,
          demande: {
            changement_chauffage: ''
          }
        }
        expect(response).to redirect_to projet_demande_path(projet)
        expect(flash[:alert]).to eq I18n.t('demarrage_projet.demande.erreurs.besoin_obligatoire')
      end
    end
  end
end
