require 'rails_helper'
require 'support/mpal_helper'
require 'support/api_particulier_helper'
require 'support/api_ban_helper'

describe API::PlansTravauxController do
  before(:each) { set_token_header('test') }
  describe "ajoute un plan de travaux" do 
    let(:projet) { FactoryGirl.create(:projet) }
    it "ajoute un plan de travaux pour un projet donné" do
      plan = [ { libelle: 'chaudiere z27', entreprise: 'DUPONT Cie', montant: 2700.50, recevable: true } ]
      post :create, plan.to_json, projet_id: projet.id, "CONTENT_TYPE": 'application/json'
      expect(response.status).to eq(201)
      expect(projet.prestations.first.libelle).to eq("chaudiere z27")
    end

    it "remplace un plan de travaux pour un projet avec un plan existant" do
      plan = [ { libelle: 'chaudiere z27', entreprise: 'DUPONT Cie', montant: 2700.50, recevable: true } ]
      plan2 = [ { libelle: 'chaudiere z28', entreprise: 'DUPONT Cie', montant: 2700.50, recevable: true } ]
      post :create, plan.to_json, projet_id: projet.id, "CONTENT_TYPE": 'application/json'
      post :create, plan2.to_json, projet_id: projet.id, "CONTENT_TYPE": 'application/json'
      expect(response.status).to eq(200)
      expect(projet.prestations.first.libelle).to eq("chaudiere z28")
      expect(projet.prestations.count).to eq(1)
    
    end
  end
end
