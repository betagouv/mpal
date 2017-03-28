require 'rails_helper'
require 'support/mpal_helper'

describe OccupantsController do
  let(:projet) { create :projet, :with_avis_imposition }

  before(:each) do
    authenticate_as_particulier(projet.numero_fiscal)
  end

  describe "#index" do
    context "get" do
      it "affiche les occupants" do
        get :index, projet_id: projet.id
        expect(response).to have_http_status(:success)
        expect(response).to render_template("index")
        expect(assigns(:occupants)).to eq projet.occupants
      end
    end

    context "post" do
      before do
        post :index, projet_id: projet.id, occupant: occupant_params
      end

      context "quand un nouvel occupant est renseigné" do
        context "si l'occupant est valide" do
          let(:occupant_params) do
            {
              prenom:            "David",
              nom:               "Graeber",
              date_de_naissance: "12/02/1961"
            }
          end

          it "enregistre un nouvel occupant" do
            expect(projet.occupants.last.persisted?).to be true
            expect(projet.occupants.last.prenom).to eq "David"
            expect(projet.occupants.last.nom).to    eq "Graeber"
            expect(projet.occupants.last.date_de_naissance).to eq DateTime.new(1961, 02, 12)
          end

          it "affiche les occupants" do
            expect(response).to have_http_status(:success)
            expect(response).to render_template("index")
            expect(assigns(:occupants)).to eq projet.occupants
          end

          it "réinitialise les champs du formulaire" do
            expect(assigns(:occupant).prenom).to            be_blank
            expect(assigns(:occupant).nom).to               be_blank
            expect(assigns(:occupant).date_de_naissance).to be_blank
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
            expect(occupant.errors).to be_present
            expect(response.body).to include occupant.errors.full_messages.first
          end
        end
      end

      context "sans occupant renseigné" do
        let(:occupant_params) do
          {
            prenom:            "",
            nom:               "",
            date_de_naissance: ""
          }
        end

        it "passe à l'étape suivante" do
          expect(response).to redirect_to(etape2_description_projet_path(projet))
        end
      end
    end
  end
end
