require 'rails_helper'
require 'support/api_particulier_helper'
require 'support/api_ban_helper'
require 'support/mpal_helper'

describe ProjetsController do
  describe "#new" do
    context "quand le demandeur est identifié" do
      let(:user) { create :user }
      before(:each) { authenticate_as_user(user) }

      context "si le projet existe" do
        let!(:projet) { create :projet, :en_cours, user: user }

        it "redirige sur la page projet" do
          get :new
          expect(response).to redirect_to projet_path(projet)
        end
      end

      context "si le projet n’existe pas" do
        it "affiche le formulaire" do
          get :new
          expect(response).to have_http_status(:success)
          expect(response).to render_template("new")
        end
      end
    end

    context "quand le demandeur a un `project_id` dans sa session" do
      context "si le projet existe" do
        let(:projet) { create :projet, :en_cours }

        it "redirige sur la page projet" do
          get :new, nil, { project_id: projet.id }
          expect(response).to redirect_to projet_path(projet)
        end
      end

      context "si le projet n’existe pas" do
        it "affiche le formulaire" do
          get :new, nil, { project_id: 42 }
          expect(response).to have_http_status(:success)
          expect(response).to render_template("new")
          expect(session[:project_id]).to be_nil
        end
      end
    end
  end

  describe "#create" do
    context "quand le projet n'existe pas encore" do
      let(:numero_fiscal)  { Fakeweb::ApiParticulier::NUMERO_FISCAL }
      let(:reference_avis) { Fakeweb::ApiParticulier::REFERENCE_AVIS }
      let(:projet)         { Projet.last }

      it "il obtient un message d’erreur" do
        post :create, projet: { numero_fiscal: numero_fiscal, reference_avis: reference_avis }, proprietaire: "0"
        expect(response).to render_template("new")
        expect(flash[:alert]).to be_present
      end

      context "quand le demandeur n’est pas propriétaire" do
        it "il obtient un message d’erreur"do
          post :create, projet: { numero_fiscal: numero_fiscal, reference_avis: reference_avis, proprietaire: "0" }
          expect(response).to render_template("new")
          expect(flash[:alert]).to be_present
        end
      end

      it "je suis redirigé vers la page de démarrage du projet" do
        post :create, projet: { numero_fiscal: numero_fiscal, reference_avis: reference_avis}, proprietaire: "1"
        expect(response).to redirect_to projet_demandeur_path(projet)
      end

      context "quand mon numero fiscal se termine par une lettre" do
        let(:numero_fiscal)  { Fakeweb::ApiParticulier::NUMERO_FISCAL.to_s + 'C' }

        it "je suis redirigé vers la page de démarrage du projet" do
          post :create, projet: {  numero_fiscal: numero_fiscal, reference_avis: reference_avis}, proprietaire: "1"
          expect(response).to redirect_to projet_demandeur_path(projet)
        end
      end

      context "quand l'année de revenus n'est pas valide" do
        let(:numero_fiscal)  { Fakeweb::ApiParticulier::NUMERO_FISCAL_ANNEE_INVALIDE }
        let(:reference_avis) { Fakeweb::ApiParticulier::REFERENCE_AVIS_ANNEE_INVALIDE }

        it "il obtient un message d'erreur" do
          post :create, projet: { numero_fiscal: numero_fiscal, reference_avis: reference_avis, proprietaire: "1" }
          expect(response).to render_template("new")
          expect(flash[:alert]).to be_present
        end
      end

      context "quand l'API BAN n'est pas disponible" do
        before { Fakeweb::ApiBan.register_all_unavailable }

        it "je suis redirigé vers la page de démarrage du projet" do
          post :create, projet: { numero_fiscal: numero_fiscal, reference_avis: reference_avis}, proprietaire: "1"
          expect(response).to redirect_to projet_demandeur_path(projet)
          expect(projet.adresse).to be nil
        end
      end

      context "quand l'adresse est inconnue" do
        before { Fakeweb::ApiBan.register_all_unknown }

        it "je suis redirigé vers la page de démarrage du projet" do
          post :create, projet: { numero_fiscal: numero_fiscal, reference_avis: reference_avis}, proprietaire: "1"
          expect(response).to redirect_to projet_demandeur_path(projet)
          expect(projet.adresse).to be nil
        end
      end
    end

    context "quand le projet existe déjà" do
      let(:projet)         { create :projet, :en_cours }
      let(:numero_fiscal)  { projet.numero_fiscal }
      let(:reference_avis) { projet.reference_avis }

      it "je suis redirigé vers la page principale du projet" do
        post :create, projet: { numero_fiscal: numero_fiscal, reference_avis: reference_avis}, proprietaire: "1" 
        expect(response).to redirect_to projet_path(projet)
      end
    end
  end
end
