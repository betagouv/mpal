require 'rails_helper'
require 'support/rod_helper'

describe Rod do
  describe "#query_for" do
    let(:projet)           { create :projet, :with_demandeur, :with_demande }
    subject(:rod_response) { Rod.new(RodClient).query_for(projet) }

    context "en cas de succès" do
      context "si des intervenants n'existent pas " do
        it "crée les PRIS manquants" do
          expect(rod_response.pris.raison_sociale).to    eq "ADIL du Doubs"
          expect(rod_response.pris.adresse_postale).to   eq "1 chemin de Ronde du Fort Griffon 25000 Besançon"
          expect(rod_response.pris.email).to             eq "adil25@orange.fr"
          expect(rod_response.pris.phone).to             eq "03 81 61 92 41"
          expect(rod_response.pris.roles).to             include "pris"
          expect(rod_response.pris.clavis_service_id).to eq "5421"
        end

        it "crée les instructeurs manquants" do
          expect(rod_response.instructeur.raison_sociale).to    eq "Direction Départementale des Territoires du Doubs"
          expect(rod_response.instructeur.adresse_postale).to   eq "6 Rue Roussillon 25003 BESANCON CEDEX"
          expect(rod_response.instructeur.email).to             eq "ddt@doubs.gouv.fr"
          expect(rod_response.instructeur.phone).to             eq "03 81 65 62 62"
          expect(rod_response.instructeur.roles).to             include "instructeur"
          expect(rod_response.instructeur.clavis_service_id).to eq "5054"
        end

        context "sans opérations programmées" do
          it "crée les opérateurs manquants" do
            expect(rod_response.operateurs.first.raison_sociale).to    eq "SOLIHA 25-90"
            expect(rod_response.operateurs.first.email).to             eq "demo-operateur@anah.gouv.fr"
            expect(rod_response.operateurs.first.roles).to             include "operateur"
            expect(rod_response.operateurs.first.clavis_service_id).to eq "5262"

            expect(rod_response.operateurs.last.raison_sociale).to    eq "AJJ"
            expect(rod_response.operateurs.last.email).to             eq "operateur25-1@anah.gouv.fr"
            expect(rod_response.operateurs.last.roles).to             include "operateur"
            expect(rod_response.operateurs.last.clavis_service_id).to eq "5267"
          end
        end

        context "avec opérations programmées" do
          before { Fakeweb::Rod.register_query_for_success_with_operation_programmee }

          it "crée les opérateurs manquants" do
            expect(rod_response.operateurs.first.raison_sociale).to    eq "SOLIHA 25-90"
            expect(rod_response.operateurs.first.email).to             eq "demo-operateur@anah.gouv.fr"
            expect(rod_response.operateurs.first.roles).to             include "operateur"
            expect(rod_response.operateurs.first.clavis_service_id).to eq "5262"

            expect(rod_response.operateurs.last.raison_sociale).to    eq "AJJ"
            expect(rod_response.operateurs.last.email).to             eq "operateur25-1@anah.gouv.fr"
            expect(rod_response.operateurs.last.roles).to             include "operateur"
            expect(rod_response.operateurs.last.clavis_service_id).to eq "5267"
          end
        end
      end

      context "si un intervenant correspondant existe déjà" do
        let!(:pris)        { create :pris,        clavis_service_id: 5421, roles: [] }
        let!(:instructeur) { create :instructeur, clavis_service_id: 5054, roles: [] }
        let!(:operateur1)  { create :operateur,   clavis_service_id: 5262, roles: [] }
        let!(:operateur2)  { create :operateur,   clavis_service_id: 5267, roles: [] }

        it "met à jour les informations du PRIS" do
          expect(rod_response.pris.id).to                  eq pris.id
          expect(rod_response.pris.raison_sociale).to      eq "ADIL du Doubs"
          expect(rod_response.pris.adresse_postale).to     eq "1 chemin de Ronde du Fort Griffon 25000 Besançon"
          expect(rod_response.pris.email).to               eq "adil25@orange.fr"
          expect(rod_response.pris.phone).to               eq "03 81 61 92 41"
          expect(rod_response.pris.roles).to               include "pris"
          expect(rod_response.pris.clavis_service_id).to eq "5421"
        end

        it "met à jour les informations de l'instructeur" do
          expect(rod_response.instructeur.id).to                eq instructeur.id
          expect(rod_response.instructeur.raison_sociale).to    eq "Direction Départementale des Territoires du Doubs"
          expect(rod_response.instructeur.adresse_postale).to   eq "6 Rue Roussillon 25003 BESANCON CEDEX"
          expect(rod_response.instructeur.email).to             eq "ddt@doubs.gouv.fr"
          expect(rod_response.instructeur.phone).to             eq "03 81 65 62 62"
          expect(rod_response.instructeur.roles).to             include "instructeur"
          expect(rod_response.instructeur.clavis_service_id).to eq "5054"
        end

        context "sans opérations programmées" do
          it "met à jour les informations des opérateurs" do
            expect(rod_response.operateurs.first.raison_sociale).to    eq "SOLIHA 25-90"
            expect(rod_response.operateurs.first.email).to             eq "demo-operateur@anah.gouv.fr"
            expect(rod_response.operateurs.first.roles).to             include "operateur"
            expect(rod_response.operateurs.first.clavis_service_id).to eq "5262"

            expect(rod_response.operateurs.last.raison_sociale).to    eq "AJJ"
            expect(rod_response.operateurs.last.email).to             eq "operateur25-1@anah.gouv.fr"
            expect(rod_response.operateurs.last.roles).to             include "operateur"
            expect(rod_response.operateurs.last.clavis_service_id).to eq "5267"
          end
        end

        context "avec opérations programmées" do
          before { Fakeweb::Rod.register_query_for_success_with_operation_programmee }

          it "met à jour les informations dees opérateurs" do
            expect(rod_response.operateurs.first.raison_sociale).to    eq "SOLIHA 25-90"
            expect(rod_response.operateurs.first.email).to             eq "demo-operateur@anah.gouv.fr"
            expect(rod_response.operateurs.first.roles).to             include "operateur"
            expect(rod_response.operateurs.first.clavis_service_id).to eq "5262"

            expect(rod_response.operateurs.last.raison_sociale).to    eq "AJJ"
            expect(rod_response.operateurs.last.email).to             eq "operateur25-1@anah.gouv.fr"
            expect(rod_response.operateurs.last.roles).to             include "operateur"
            expect(rod_response.operateurs.last.clavis_service_id).to eq "5267"
          end
        end
      end
    end

    context "en cas d'erreur" do
      before { Fakeweb::Rod.register_query_for_failure }

      it "lève une exception avec le message d'erreur" do
        expect{rod_response}.to raise_error(RodError, "Applicant's adress is not found. Check if adress is correct")
      end
    end
  end
end
