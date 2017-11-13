require "rails_helper"
require "support/mpal_helper"
require "support/api_particulier_helper"
require "support/api_ban_helper"
require "support/rod_helper"

describe MisesEnRelationController do
  let(:projet)     { create :projet, :prospect }

  before(:each) { authenticate_as_project projet.id }

  describe "#show" do
    before do
      create :pris
      get :show, params: { projet_id: projet.id }
    end

    it "renders the template" do
      expect(response).to render_template(:show)
      expect(assigns(:page_heading)).to eq I18n.t("demarrage_projet.mise_en_relation.assignement_pris_titre")
    end

    context "si le demandeur est en opération programmée" do
      before do
        Fakeweb::Rod.register_query_for_success_with_operation
        expect_any_instance_of(RodResponse).to receive(:scheduled_operation?).and_return(true)
      end

      context "s'il est éligible" do
        it "met à jour le projet, n’invite pas le PRIS et invite l’instructeur" do
          get :show, params: { projet_id: projet.id }
          expect(response).to render_template(:scheduled_operation)
        end
      end

      context "s'il n'est pas éligible" do

        before { projet.avis_impositions.first.update(revenu_fiscal_reference: 1000000) }

        it "il est mis en relation avec le PRIS EIE" do
          get :show, params: { projet_id: projet.id }
          expect(response).to render_template(:show)
        end
      end
    end
  end

  describe "#update" do
    context "quand les paramètres sont valides" do
      context "sans opérations programmées" do
        before do
          patch :update, params: {
            projet_id: projet.id,
            projet: {
              disponibilite: "plutôt le matin"
            }
          }
          projet.reload
        end

        it "met à jour le projet et invite le PRIS et l’instructeur" do
          expect(projet.disponibilite).to eq "plutôt le matin"
          expect(projet.invited_pris).to be_present
          expect(projet.invited_instructeur).to be_present
        end

        it "redirige vers la page principale du projet" do
          expect(response).to redirect_to projet_path(projet)
          expect(flash[:success]).to eq I18n.t("invitations.messages.succes", intervenant: projet.invited_pris.raison_sociale)
        end
      end

      context "avec une seule opération programmée avec un opérateur" do
        before do
          Fakeweb::Rod.register_query_for_success_with_operation
          patch :update, params: {
            projet_id: projet.id,
            projet: {
              disponibilite: "plutôt le matin"
            }
          }
          projet.reload
        end

        it "met à jour le projet, n’invite pas le PRIS et invite l’instructeur" do
          expect(projet.disponibilite).to eq "plutôt le matin"
          expect(projet.invited_pris).not_to be_present
          expect(projet.invited_instructeur).to be_present
          expect(projet.operateur).to be_present
        end
      end

      context "quand il y a plusieurs opérations programmées" do
        before do
          Fakeweb::Rod.register_query_for_success_with_operations
          patch :update, params: {
            projet_id: projet.id,
            projet: {
              disponibilite: "plutôt le matin"
            }
          }
          projet.reload
        end

        it "met à jour le projet et invite le PRIS et l’instructeur" do
          expect(projet.disponibilite).to eq "plutôt le matin"
          expect(projet.invited_pris).to be_present
          expect(projet.invited_instructeur).to be_present
        end
      end
    end
  end
end
