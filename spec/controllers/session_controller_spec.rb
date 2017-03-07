require 'rails_helper'
require 'support/api_particulier_helper'
require 'support/api_ban_helper'

describe SessionsController do
  describe "#create" do
    context "quand le projet n'existe pas encore" do
      let(:numero_fiscal)  { Fakeweb::ApiParticulier::NUMERO_FISCAL }
      let(:reference_avis) { Fakeweb::ApiParticulier::REFERENCE_AVIS }
      let(:projet)         { Projet.last }

      it "je suis redirigé vers la page de démarrage du projet" do
        post :create, numero_fiscal: numero_fiscal, reference_avis: reference_avis
        expect(response).to redirect_to etape1_recuperation_infos_path(projet)
      end

      context "quand l'API BAN n'est pas disponible" do
        before { Fakeweb::ApiBan.register_all_unavailable }

        it "je suis redirigé vers la page de démarrage du projet" do
          post :create, numero_fiscal: numero_fiscal, reference_avis: reference_avis
          expect(response).to redirect_to etape1_recuperation_infos_path(projet)
          expect(projet.adresse).to be nil
        end
      end

      context "quand l'adresse est inconnue" do
        before { Fakeweb::ApiBan.register_all_unknown }

        it "je suis redirigé vers la page de démarrage du projet" do
          post :create, numero_fiscal: numero_fiscal, reference_avis: reference_avis
          expect(response).to redirect_to etape1_recuperation_infos_path(projet)
          expect(projet.adresse).to be nil
        end
      end
    end

    context "quand le projet existe déjà" do
      let(:projet)         { create :projet, :en_cours }
      let(:numero_fiscal)  { projet.numero_fiscal }
      let(:reference_avis) { projet.reference_avis }

      it "je suis redirigé vers la page principale du projet" do
        post :create, numero_fiscal: numero_fiscal, reference_avis: reference_avis
        expect(response).to redirect_to projet_path(projet)
      end
    end
  end
end
