require 'rails_helper'
require 'support/mpal_helper'
require 'support/api_ban_helper'

describe MisesEnRelationController do
  let(:projet) { create :projet, :prospect }

  before(:each) do
    authenticate_as_particulier(projet.numero_fiscal)
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
      let(:pris) { create :pris }

      before do
        patch :update, {
          projet_id: projet.id,
          projet: {
            disponibilite: 'plutôt le matin'
          },
          intervenant: pris.id
        }
        projet.reload
      end

      it "met à jour le projet" do
        expect(projet.disponibilite).to eq "plutôt le matin"
        expect(projet.invited_pris).to eq pris
      end

      it "redirige vers la page principale du projet" do
        expect(response).to redirect_to projet_path(projet)
        expect(flash[:notice_titre]).to eq I18n.t('invitations.messages.succes_titre')
        expect(flash[:notice]).to eq I18n.t('invitations.messages.succes', intervenant: pris.raison_sociale)
      end
    end

    context "quand une erreur se produit lors de l'enregistrement" do
      it "affiche une erreur" do
        patch :update, {
          projet_id: projet.id,
          projet: nil,
          intervenant_id: nil
        }
        expect(response).to redirect_to projet_mise_en_relation_path(projet)
        expect(flash[:alert]).to eq I18n.t('demarrage_projet.mise_en_relation.error')
      end
    end
  end
end
