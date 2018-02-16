require "rails_helper"
require "support/mpal_helper"

describe OccupantsController do
  let(:projet) { create :projet, :with_demandeur }

  before(:each) { authenticate_as_project projet.id }

  describe "#index" do
    context "get" do
      it "affiche les occupants" do
        get :index, params: { projet_id: projet.id }
        expect(response).to have_http_status(:success)
        expect(response).to render_template("index")
        expect(assigns(:occupants)).to eq projet.occupants
      end
    end

    context "post" do
      let(:submit_button_params) { {} }

      before do
        post :index, params: {
          projet_id: projet.id,
          occupant: occupant_params,
        }.merge(submit_button_params)
      end

      context "quand un nouvel occupant est renseigné" do
        context "si l’occupant est valide" do
          let(:occupant_params) do
            {
              prenom:            "David",
              nom:               "Graeber",
              date_de_naissance: "12/02/1961",
            }
          end

          it "enregistre un nouvel occupant" do
            expect(projet.occupants.last.persisted?).to be true
            expect(projet.occupants.last.prenom).to eq "David"
            expect(projet.occupants.last.nom).to    eq "Graeber"
            expect(projet.occupants.last.date_de_naissance).to eq DateTime.new(1961, 02, 12)
          end

          it "affiche les occupants" do
            expect(response).to redirect_to projet_occupants_path(projet)
          end
        end

        context "si l'occupant est invalide" do
          render_views
          let(:occupant_params) do
            {
              prenom:            "David",
              nom:               "Graeber",
              date_de_naissance: ""
            }
          end

          it "affiche les erreurs de validation" do
            occupant = assigns(:occupant)
            expect(occupant.errors).to be_added :date_de_naissance, :blank
            expect(response.body).to include occupant.errors.full_messages.first
          end
        end
      end

      context "avec une naissance prévue" do
        render_views
        let(:occupant_params) do
          {
            prenom:            "",
            nom:               "",
            date_de_naissance: "",
            projet: {
              future_birth: "1"
            }
          }
        end

        it "enregistre l’information" do
          projet.reload
          expect(projet.future_birth).to be_truthy # or to be alive
        end
      end

      context "sans occupant renseigné" do
        render_views
        let(:occupant_params) do
          {
            prenom:            "",
            nom:               "",
            date_de_naissance: "",
          }
        end

        context "si je clique sur le bouton de soumission" do
          let(:submit_button_params) { { submit_button: "" } }

          it "je passe à l'étape suivante" do
            expect(response).to redirect_to(projet_eligibility_path(projet))
          end
        end

        context "si je clique sur l’ajout d’occupant" do
          it "affiche les erreurs de validation" do
            occupant = assigns(:occupant)
            expect(occupant.errors).to be_added :date_de_naissance, :blank
            expect(occupant.errors).to be_added :prenom, :blank
            expect(occupant.errors).to be_added :nom, :blank
            expect(response.body).to include occupant.errors.full_messages.first
          end
        end
      end
    end
  end

  describe "#destroy" do
    context "pour un occupant demandeur" do
      let(:occupant_demandeur) { projet.occupants.first }

      it "affiche une erreur" do
        delete :destroy, params: { projet_id: projet.id, id: occupant_demandeur.id }
        expect(projet.occupants).to include occupant_demandeur
        expect(response).to redirect_to(projet_occupants_path(projet))
        expect(flash[:alert]).to eq I18n.t("occupants.delete.error")
      end
    end

    context "pour un occupant rajouté ultérieurement" do
      let(:occupant_to_delete) { projet.occupants.last }

      it "supprime l’occupant" do
        delete :destroy, params: { projet_id: projet.id, id: occupant_to_delete.id }
        expect(projet.occupants).not_to include occupant_to_delete
        expect(response).to redirect_to(projet_occupants_path(projet))
        expect(flash[:notice]).to eq I18n.t("occupants.delete.success", fullname: occupant_to_delete.fullname)
      end
    end
  end
end
