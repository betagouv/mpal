require 'rails_helper'
require 'support/mpal_helper'
require 'support/api_particulier_helper'
require 'support/api_ban_helper'

describe API::SubventionsController do
  describe "ajoute un plan de financmenet" do 
    let(:projet) { FactoryGirl.create(:projet) }
    it "ajoute un plan de financement pour un projet donné" do
      libelle = 'CD92 - Aide amélioration habitat privé' 
      plan = [ { libelle: libelle, montant: 2400.50 } ]
      post :create, plan.to_json, projet_id: projet.id, "CONTENT_TYPE": 'application/json'
      expect(response.status).to eq(201)
      expect(projet.subventions.first.libelle).to eq(libelle)
    end
  end
end
