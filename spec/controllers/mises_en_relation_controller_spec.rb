require 'rails_helper'
require 'support/mpal_helper'
require 'support/api_particulier_helper'
require 'support/api_ban_helper'
require 'support/rod_helper'

describe MisesEnRelationController do
  let(:projet) { create :projet, :prospect }

  before(:each) { authenticate_as_project(projet.id) }

  describe "#show" do
    before do
      create :pris
      get :show, projet_id: projet.id
    end

    it "renders the template" do
      expect(response).to render_template(:show)
      expect(assigns(:page_heading)).to eq 'Inscription'
    end
  end

  describe "#update" do
    context "quand les paramètres sont valides" do
      context "sans opérations programmées" do
        before do
          patch :update, {
            projet_id: projet.id,
            projet: {
              disponibilite: 'plutôt le matin'
            }
          }
          projet.reload
        end

        it "met à jour le projet et invite le PRIS et l'instructeur" do
          expect(projet.disponibilite).to eq "plutôt le matin"
          expect(projet.invited_pris).to be_present
          expect(projet.invited_instructeur).to be_present
        end

        it "redirige vers la page principale du projet" do
          expect(response).to redirect_to projet_path(projet)
          expect(flash[:notice_titre]).to eq I18n.t('invitations.messages.succes_titre')
          expect(flash[:notice]).to eq I18n.t('invitations.messages.succes', intervenant: projet.invited_pris.raison_sociale)
        end
      end

      context "avec une seule opération programmée avec un opérateur" do
        before do
          Fakeweb::Rod.register_query_for_success_with_operation
          patch :update, {
            projet_id: projet.id,
            projet: {
              disponibilite: 'plutôt le matin'
            }
          }
          projet.reload
        end

        it "met à jour le projet, n'invite pas le PRIS et invite l'instructeur" do
          expect(projet.disponibilite).to eq "plutôt le matin"
          expect(projet.invited_pris).not_to be_present
          expect(projet.invited_instructeur).to be_present
        end
      end

      context "quand il y a plusieurs opérations programmées" do
        before do
          Fakeweb::Rod.register_query_for_success_with_operations
          patch :update, {
            projet_id: projet.id,
            projet: {
              disponibilite: 'plutôt le matin'
            }
          }
          projet.reload
        end

        it "met à jour le projet et invite le PRIS et l'instructeur" do
          expect(projet.disponibilite).to eq "plutôt le matin"
          expect(projet.invited_pris).to be_present
          expect(projet.invited_instructeur).to be_present
        end
      end
    end
  end
end
