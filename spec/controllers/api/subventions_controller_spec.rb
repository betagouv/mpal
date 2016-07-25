require 'rails_helper'
require 'support/mpal_helper'
require 'support/api_particulier_helper'
require 'support/api_ban_helper'

describe API::SubventionsController do
  before(:each) { set_token_header('test') }
  let(:projet) { FactoryGirl.create(:projet) }
  describe "ajoute un plan de financmenet" do 
    it "ajoute un plan de financement pour un projet donné" do
      libelle = 'CD92 - Aide amélioration habitat privé' 
      plan = [ { libelle: libelle, montant: 2400.50 } ]
      post :create, plan.to_json, projet_id: projet.id, "CONTENT_TYPE": 'application/json'
      expect(response.status).to eq(201)
      expect(projet.subventions.first.libelle).to eq(libelle)
    end
  end

  it "remplace un plan de travaux pour un projet avec un plan existant" do
      plan = [ { libelle: 'CD92 - Aide amélioration habitat privé', montant: 2400.50 } ]
      plan2 = [ { libelle: 'Anah - Aide amélioration habitat privé', montant: 1400.10 } ]
      post :create, plan.to_json, projet_id: projet.id, "CONTENT_TYPE": 'application/json'
      post :create, plan2.to_json, projet_id: projet.id, "CONTENT_TYPE": 'application/json'
      expect(response.status).to eq(200)
      expect(projet.subventions.first.libelle).to eq("Anah - Aide amélioration habitat privé")
      expect(projet.subventions.count).to eq(1)
    
  end
end
