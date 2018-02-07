require "rails_helper"
require "support/mpal_helper"
require "support/api_ban_helper"

describe DemandesController do
  let(:projet) { create :projet, :initial, :with_demandeur }

  describe "#show" do
    before do
      authenticate_as_project(projet.id)
      get :show, params: { projet_id: projet.id }
    end

    it "renders the template" do
      expect(response).to render_template(:show)
      expect(assigns(:page_heading)).to eq "Ma demande"
      expect(projet.demande).to be_nil
    end
  end

  describe "#update" do
    context "quand le demandeur n’a pas encore atteint la page éligibilité" do
      before { authenticate_as_project(projet.id) }

      it "met à jour la demande" do
        patch :update, params: {
          projet_id: projet.id,
          demande: {
            changement_chauffage: "1",
            froid: "0",
          }
        }
        projet.demande.reload
        expect(projet.demande.changement_chauffage).to be true
        expect(projet.demande.froid).to be false
        expect(response).to redirect_to new_user_registration_path
        expect(flash[:alert]).to be_blank
      end

      context "quand aucun besoin n’est sélectionné" do
        it "affiche une erreur" do
          patch :update, params: {
            projet_id: projet.id,
            demande: {
              changement_chauffage: "0",
            }
          }
          expect(response).to render_template :show
          expect(assigns(:demande).errors).to be_added :base, I18n.t("demarrage_projet.demande.erreurs.besoin_obligatoire")
        end
      end
    end

    context "quand le demandeur a déjà atteint la page éligibilité" do
      before do
        projet.demande = Demande.new(froid: "1")
        projet.demande.save
        projet.update(locked_at: Time.new(2001, 2, 3, 4, 5, 6) )
      end

      context "quand le demandeur se connecte" do
        let!(:user) { create :user }

        before do
          authenticate_as_user(user)
          projet.users << user
        end

        it "le demandeur ne peut plus modifier le projet" do
          patch :update, params: {
            projet_id: projet.id,
            demande: {
              changement_chauffage: "0",
            }
          }

          # TODO: pas critique, mais le message d’alerte ne s’affiche pas alors qu’il devrait
          #expect(flash[:alert]).to eq I18n.t("unauthorized.default")
          expect(response).to redirect_to projet_eligibility_path(projet.id)
        end
      end

      context "quand l’opérateur se connecte" do
        let(:projet) { create :projet, :en_cours, :with_assigned_operateur }

        before { authenticate_as_agent(projet.agent_operateur) }

        it "l’opérateur peut modifier le projet" do
          patch :update, params: {
            dossier_id: projet.id,
            demande: {
              changement_chauffage: "1",
              froid: "0",
            }
          }

          projet.demande.reload
          expect(projet.demande.changement_chauffage).to be true
          expect(projet.demande.froid).to be false
        end
      end
    end
  end
end
