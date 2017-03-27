require 'rails_helper'

class OpalClientMock
  attr_accessor :url
  attr_accessor :body

  def post(url, options)
    @url  = url
    @body = options[:body]
    response
  end

private
  include RSpec::Mocks::ExampleMethods

  def response
    data = {
      dosNumero: "09500840",
      dosId:     959496
    }
    response = Net::HTTPResponse.new(1.1, 201, "OK")
    allow(response).to receive(:body).and_return(data.to_json)
    response
  end
end

describe Opal do
  let(:client) { OpalClientMock.new }

  describe "#creer_dossier" do
    let(:projet) {            create :projet, :transmis_pour_instruction, demandeurs_count: 1, occupants_a_charge_count: 1 }
    let(:instructeur) {       create :instructeur }
    let(:agent_instructeur) { create :agent, intervenant: instructeur }

    subject! { Opal.new(client).creer_dossier(projet, agent_instructeur) }

    it "envoie les informations sérialisées" do
      body = JSON.parse(client.body)
      expect(body["dosNumeroPlateforme"]).to eq projet.numero_plateforme
      expect(body["dosDateDepot"]).to be_present
      expect(body["utiIdClavis"]).to eq agent_instructeur.clavis_id

      demandeur = body["demandeur"]
      expect(demandeur["dmdNbOccupants"]).to eq 2
      expect(demandeur["dmdRevenuOccupants"]).to eq projet.revenu_fiscal_reference_total

      personne_physique = demandeur["personnePhysique"]
      expect(personne_physique["civId"]).to eq 1
      expect(personne_physique["pphPrenom"]).to eq "Jean et Jean"
      expect(personne_physique["pphNom"]).to start_with "MARTIN"

      adresse_postale = personne_physique["adressePostale"]
      expect(adresse_postale["adpLigne1"]).to eq "65 rue de Rome"
      expect(adresse_postale["adpLocalite"]).to eq "Paris"
      expect(adresse_postale["adpCodePostal"]).to eq "75008"

      immeuble = body["immeuble"]
      expect(immeuble["immAnneeAchevement"]).to eq 1975

      adresse_geographique = immeuble["adresseGeographique"]
      expect(adresse_geographique["adgLigne1"]).to eq "12 rue de la Mare"
      expect(adresse_geographique["cdpCodePostal"]).to eq "75010"
      expect(adresse_geographique["comCodeInsee"]).to eq "010"
      expect(adresse_geographique["dptNumero"]).to eq "75"
    end

    it "met à jour le dossier avec la réponse d'Opal" do
      expect(subject).to be true
      expect(projet.opal_id).to eq("959496")
      expect(projet.opal_numero).to eq("09500840")
      expect(projet.statut).to eq('en_cours_d_instruction')
      expect(projet.agent_instructeur).to eq(agent_instructeur)
    end
  end

  describe ".split_adresse_into_lines" do
    let(:opal)              { Opal.new(client) }

    subject(:adresse_lines) { opal.send(:split_adresse_into_lines, adresse) }

    context "quand l'adresse est courte" do
      let(:adresse) { "15 Rue Principale" }

      it "ne fait rien" do
        expect(adresse_lines[0]).to eq "15 Rue Principale"
        expect(adresse_lines[1]).to eq ""
        expect(adresse_lines[2]).to eq ""
      end
    end

    context "quand l'adresse est longue" do
      let(:adresse) { "15 Rue Principale (Bonnevaux le Prieuré)" }

      it "sépare l'adresse selon le dernier espace rencontré" do
        expect(adresse_lines[0]).to eq "15 Rue Principale (Bonnevaux le "
        expect(adresse_lines[1]).to eq "Prieuré)"
        expect(adresse_lines[2]).to eq ""
      end
    end

    context "quand l'adresse est très longue" do
      let(:adresse) { "1080 Boulevard Of Broken Dreams (Endroit-Fantasque-Sorti-Directement-De-Mon-Imagination-Debordante)" }

      it "sépare l'adresse selon le dernier tiret rencontré" do
        expect(adresse_lines[0]).to eq "1080 Boulevard Of Broken Dreams "
        expect(adresse_lines[1]).to eq "(Endroit-Fantasque-Sorti-Directement-"
        expect(adresse_lines[2]).to eq "De-Mon-Imagination-Debordante)"
      end
    end

    context "quand l’adresse est trop longue" do
      let(:adresse) { "Boulevard du Président John Fitzgerald Kennedy et il faut rajouter des mots" }

      it "découpe en lignes de moins de 38 caractères" do
        expect(adresse_lines[0].length).to be <= 38
        expect(adresse_lines[1].length).to be <= 38
        expect(adresse_lines[2].length).to be <= 38
      end
    end
  end
end



