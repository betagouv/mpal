require 'rails_helper'
require 'support/rod_helper'

describe Rod do
  describe "#create_intervenant" do
    let(:clavis_service_id) { "1234" }
    subject(:intervenant) { Rod.new(RodClient).create_intervenant(clavis_service_id) }
    before { Fakeweb::Rod.register_intervenant }

    it {
      expect(intervenant.clavis_service_id).to eq clavis_service_id
      expect(intervenant.raison_sociale).to    eq "DREAL Provence-Alpes-Côte d'Azur"
      expect(intervenant.adresse_postale).to   eq "16 Rue Zattara CS 70248 13331 MARSEILLE CEDEX"
      expect(intervenant.departements).to      eq ["04", "05", "06", "13", "83", "84"]
      expect(intervenant.email).to             eq "contact@example.com"
      expect(intervenant.roles).to             eq ["dreal"]
      expect(intervenant.phone).to             eq "0102030405"
    }
  end

  describe "#create_intervenant!" do
    let(:clavis_service_id) { "1234" }
    let(:rod) { Rod.new(RodClient) }
    subject(:intervenant) { rod.create_intervenant!(clavis_service_id) }
    before { Fakeweb::Rod.register_intervenant }

    it {
      expect(rod).to receive(:create_intervenant).once.and_call_original
      expect(intervenant).to be_persisted
    }
  end

  describe "#list_intervenants_rod" do
    let(:departement) { "25" }
    subject(:response) { Rod.new(RodClient).list_intervenants_rod(departement) }
    before { Fakeweb::Rod.list_department_intervenants_helper }

    it { expect(subject).to eq(Fakeweb::Rod::FakeResponseList.with_indifferent_access) }
  end

  describe "#query_for" do
    let(:projet)           { create :projet, :with_demandeur, :with_demande }
    subject(:rod_response) { Rod.new(RodClient).query_for(projet) }

    context "en cas de succès" do
      context "si le PRIS n'existe pas " do
        it "crée le PRIS" do
          expect(rod_response.pris.raison_sociale).to    eq "ADIL du Doubs"
          expect(rod_response.pris.adresse_postale).to   eq "1 chemin de Ronde du Fort Griffon 25000 Besançon"
          expect(rod_response.pris.email).to             eq "adil25@orange.fr"
          expect(rod_response.pris.phone).to             eq "03 81 61 92 41"
          expect(rod_response.pris.roles).to             include "pris"
          expect(rod_response.pris.clavis_service_id).to eq "5421"
        end
      end

      context "si le PRIS existe" do
        let!(:pris) { create :pris, clavis_service_id: 5421, roles: [] }

        it "met à jour les informations du PRIS" do
          expect(rod_response.pris.id).to                  eq pris.id
          expect(rod_response.pris.raison_sociale).to      eq "ADIL du Doubs"
          expect(rod_response.pris.adresse_postale).to     eq "1 chemin de Ronde du Fort Griffon 25000 Besançon"
          expect(rod_response.pris.email).to               eq "adil25@orange.fr"
          expect(rod_response.pris.phone).to               eq "03 81 61 92 41"
          expect(rod_response.pris.roles).to               include "pris"
          expect(rod_response.pris.clavis_service_id).to eq "5421"
        end
      end

      context "si le PRIS EIE n'existe pas " do
        it "crée le PRIS EIE" do
          expect(rod_response.pris_eie.raison_sociale).to    eq "ADIL Doudoux"
          expect(rod_response.pris_eie.adresse_postale).to   eq "1 chemin de Ronde du Fort Griffon 25000 Besançon"
          expect(rod_response.pris_eie.email).to             eq "adil25@orange.fr"
          expect(rod_response.pris_eie.phone).to             eq "03 81 61 92 41"
          expect(rod_response.pris_eie.roles).to             include "pris"
          expect(rod_response.pris_eie.clavis_service_id).to eq "5422"
        end
      end

      context "si le PRIS EIE existe" do
        let!(:pris_eie) { create :pris, clavis_service_id: 5422, roles: [] }

        it "met à jour les informations du PRIS EIE" do
          expect(rod_response.pris_eie.id).to                  eq pris_eie.id
          expect(rod_response.pris_eie.raison_sociale).to      eq "ADIL Doudoux"
          expect(rod_response.pris_eie.adresse_postale).to     eq "1 chemin de Ronde du Fort Griffon 25000 Besançon"
          expect(rod_response.pris_eie.email).to               eq "adil25@orange.fr"
          expect(rod_response.pris_eie.phone).to               eq "03 81 61 92 41"
          expect(rod_response.pris_eie.roles).to               include "pris"
          expect(rod_response.pris_eie.clavis_service_id).to eq "5422"
        end
      end

      context "si l'instructeur n'existe pas" do
        it "crée l'instructeur" do
          expect(rod_response.instructeur.raison_sociale).to    eq "Direction Départementale des Territoires du Doubs"
          expect(rod_response.instructeur.adresse_postale).to   eq "6 Rue Roussillon 25003 BESANCON CEDEX"
          expect(rod_response.instructeur.email).to             eq "ddt@doubs.gouv.fr"
          expect(rod_response.instructeur.phone).to             eq "03 81 65 62 62"
          expect(rod_response.instructeur.roles).to             include "instructeur"
          expect(rod_response.instructeur.clavis_service_id).to eq "5054"
        end
      end

      context "si l'instructeur existe" do
        let!(:instructeur) { create :instructeur, clavis_service_id: 5054, roles: [] }

        it "met à jour les informations de l'instructeur" do
          expect(rod_response.instructeur.id).to                eq instructeur.id
          expect(rod_response.instructeur.raison_sociale).to    eq "Direction Départementale des Territoires du Doubs"
          expect(rod_response.instructeur.adresse_postale).to   eq "6 Rue Roussillon 25003 BESANCON CEDEX"
          expect(rod_response.instructeur.email).to             eq "ddt@doubs.gouv.fr"
          expect(rod_response.instructeur.phone).to             eq "03 81 65 62 62"
          expect(rod_response.instructeur.roles).to             include "instructeur"
          expect(rod_response.instructeur.clavis_service_id).to eq "5054"
        end
      end

      context "si des opérations programmées n'existent pas" do
        before { Fakeweb::Rod.register_query_for_success_with_operations }

        it "crée les opérations programmées" do
          expect(rod_response.operations.first.name).to      eq "PIG"
          expect(rod_response.operations.first.code_opal).to eq "1A"

          expect(rod_response.operations.last.name).to      eq "PORCINET"
          expect(rod_response.operations.last.code_opal).to eq "1B"
        end
        context "si les opérateurs n'existent pas" do
          it "crée les opérateurs" do
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

        context "si les opérateurs existent" do
          let!(:operateur1) { create :operateur, clavis_service_id: 5262, roles: [] }
          let!(:operateur2) { create :operateur, clavis_service_id: 5267, roles: [] }

          it "met à jour les informations des opérateurs" do
            expect(rod_response.operateurs.first.id).to                eq operateur1.id
            expect(rod_response.operateurs.first.raison_sociale).to    eq "SOLIHA 25-90"
            expect(rod_response.operateurs.first.email).to             eq "demo-operateur@anah.gouv.fr"
            expect(rod_response.operateurs.first.roles).to             include "operateur"
            expect(rod_response.operateurs.first.clavis_service_id).to eq "5262"

            expect(rod_response.operateurs.last.id).to                eq operateur2.id
            expect(rod_response.operateurs.last.raison_sociale).to    eq "AJJ"
            expect(rod_response.operateurs.last.email).to             eq "operateur25-1@anah.gouv.fr"
            expect(rod_response.operateurs.last.roles).to             include "operateur"
            expect(rod_response.operateurs.last.clavis_service_id).to eq "5267"
          end
        end
      end

      context "si les opérations programmées existent" do
        let!(:operation1) { create :operation, code_opal: "1A" }
        let!(:operation2) { create :operation, code_opal: "1B" }

        before { Fakeweb::Rod.register_query_for_success_with_operations }

        it "met à jour les informations des opérations programmées" do
          expect(rod_response.operations.first.id).to        eq operation1.id
          expect(rod_response.operations.first.name).to      eq "PIG"
          expect(rod_response.operations.first.code_opal).to eq "1A"

          expect(rod_response.operations.last.id).to        eq operation2.id
          expect(rod_response.operations.last.name).to      eq "PORCINET"
          expect(rod_response.operations.last.code_opal).to eq "1B"
        end

        context "si les opérateurs n'existent pas" do
          it "crée les opérateurs" do
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

        context "si les opérateurs existent" do
          let!(:operateur1) { create :operateur, clavis_service_id: 5262, roles: [] }
          let!(:operateur2) { create :operateur, clavis_service_id: 5267, roles: [] }

          it "met à jour les informations des opérateurs" do
            expect(rod_response.operateurs.first.id).to                eq operateur1.id
            expect(rod_response.operateurs.first.raison_sociale).to    eq "SOLIHA 25-90"
            expect(rod_response.operateurs.first.email).to             eq "demo-operateur@anah.gouv.fr"
            expect(rod_response.operateurs.first.roles).to             include "operateur"
            expect(rod_response.operateurs.first.clavis_service_id).to eq "5262"

            expect(rod_response.operateurs.last.id).to                eq operateur2.id
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
