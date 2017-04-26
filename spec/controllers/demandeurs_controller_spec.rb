require 'rails_helper'
require 'support/mpal_helper'
require 'support/api_ban_helper'

describe DemandeursController do
  let(:projet) { create :projet, :prospect, declarants_count: 2 }

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
    let(:projet_params) do {} end
    let(:params) do
      default_params = { adresse_postale: projet.adresse_postale.description }
      {
        contact: "1",
        projet_id: projet.id,
        projet:    default_params.merge(projet_params)
      }
    end

    before(:each) do
      post :update, params
      projet.reload
    end

    context "lorsque les informations changent" do
      let(:projet_params) do
        {
          tel:   '01 02 03 04 05',
          email: 'particulier@exemple.fr'
        }
      end

      it "enregistre les informations modifiées" do
        expect(response).to redirect_to projet_avis_impositions_path(projet)
        expect(projet.tel).to eq   '01 02 03 04 05'
        expect(projet.email).to eq 'particulier@exemple.fr'
      end
    end

    context "lorsque la personne de confiance est renseignée" do
      let(:projet_params) do
        {
          personne_attributes: {
            civilite:            'mr',
            prenom:              'Tyrone',
            nom:                 'Meehan',
            tel:                 '01 02 03 04 05',
            lien_avec_demandeur: 'ami'
          }
        }
      end

      it "enregistre la personne de confiance" do
        expect(response).to redirect_to projet_avis_impositions_path(projet)
        expect(projet.personne.civilite).to            eq 'mr'
        expect(projet.personne.prenom).to              eq 'Tyrone'
        expect(projet.personne.nom).to                 eq 'Meehan'
        expect(projet.personne.tel).to                 eq '01 02 03 04 05'
        expect(projet.personne.lien_avec_demandeur).to eq 'ami'
      end
    end

    context "lorsque l'adresse postale est vide" do
      let(:projet_params) do { adresse_postale: '' } end

      it "affiche une erreur" do
        expect(response).to render_template(:show)
        expect(flash[:alert]).to eq I18n.t('demarrage_projet.demandeur.erreurs.adresse_vide')
      end
    end

    context "lorsque l'adresse postale n'a pas changée" do
      let!(:adresse_initiale) { projet.adresse_postale }
      let(:projet_params) do { adresse_postale: projet.adresse_postale.description } end

      it "conserve l'adresse existante" do
        expect_any_instance_of(ApiBan).not_to receive(:precise)
        expect(projet.adresse_postale).to eq adresse_initiale
      end
    end

    context "lorsque l'adresse postale est mise à jour" do
      context "et est disponible dans la BAN" do
        let(:projet_params) do { adresse_postale: Fakeweb::ApiBan::ADDRESS_PORT } end

        it "enregistre l'adresse précisée" do
          expect(projet.adresse_postale).to be_present
          expect(projet.adresse_postale.ligne_1).to     eq "8 Boulevard du Port"
          expect(projet.adresse_postale.code_insee).to  eq "80021"
          expect(projet.adresse_postale.code_postal).to eq "80000"
          expect(projet.adresse_postale.ville).to       eq "Amiens"
          expect(projet.adresse_postale.departement).to eq "80"
          expect(projet.adresse_postale.region).to      eq "Hauts-de-France"
          expect(projet.adresse_postale.latitude).to    be_within(0.1).of 49.9
          expect(projet.adresse_postale.longitude).to   be_within(0.1).of 2.3
          expect(projet.adresse_postale.description).to eq Fakeweb::ApiBan::ADDRESS_PORT
        end
      end

      context "et n'est pas disponible dans la BAN" do
        let(:projet_params) do { adresse_postale: Fakeweb::ApiBan::ADDRESS_UNKNOWN } end
        it "affiche une erreur" do
          expect(response).to render_template(:show)
          expect(flash[:alert]).to eq I18n.t('demarrage_projet.demandeur.erreurs.adresse_inconnue')
        end
      end
    end

    context "lorsque l'adresse à rénover est renseignée" do
      let(:projet_params) do
        {
          adresse_postale:   Fakeweb::ApiBan::ADDRESS_MARE,
          adresse_a_renover: Fakeweb::ApiBan::ADDRESS_PORT
        }
      end
      it "enregistre l'adresse à rénover" do
        expect(projet.adresse_a_renover).to be_present
        expect(projet.adresse_a_renover.ligne_1).to     eq "8 Boulevard du Port"
        expect(projet.adresse_a_renover.code_insee).to  eq "80021"
        expect(projet.adresse_a_renover.code_postal).to eq "80000"
        expect(projet.adresse_a_renover.ville).to       eq "Amiens"
        expect(projet.adresse_a_renover.departement).to eq "80"
        expect(projet.adresse_a_renover.region).to      eq "Hauts-de-France"
        expect(projet.adresse_a_renover.latitude).to    be_within(0.1).of 49.9
        expect(projet.adresse_a_renover.longitude).to   be_within(0.1).of 2.3
        expect(projet.adresse_a_renover.description).to eq Fakeweb::ApiBan::ADDRESS_PORT
      end
    end

    context "lorsque l'adresse à rénover est supprimée" do
      let(:projet) { create :projet, :prospect, adresse_a_renover: create(:adresse) }
      let(:projet_params) do
        {
          adresse_postale:   Fakeweb::ApiBan::ADDRESS_MARE,
          adresse_a_renover: nil
        }
      end
      it "supprime l'adresse à rénover" do
        expect(projet.adresse_a_renover).to be_nil
      end
    end

    context "lorsque je renseigne le déclarant" do
      let(:projet_params) do
        {
            demandeur_id: projet.occupants.last.id,
        }
      end

      it "enregistre les informations modifiées" do
        expect(response).to redirect_to projet_avis_impositions_path(projet)
        expect(projet.demandeur_principal).to eq projet.occupants.last
      end
    end
  end

  context "lorsque une information est erronée" do
    before do
      projet.demandeur_principal.update_attribute(:civilite, nil)
      post :update, {
        contact: "1",
        projet_id: projet.id,
        projet: {
          adresse_postale: projet.adresse_postale.description,
          demandeur_id: projet.demandeur_principal.id
        }
      }
    end

    it "affiche une erreur" do
      expect(flash[:alert]).to eq I18n.t('demarrage_projet.demandeur.erreurs.enregistrement_demandeur')
    end
  end
end
