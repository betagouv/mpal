require 'rails_helper'
require 'support/mpal_helper'
require 'support/api_particulier_helper'
require 'support/api_ban_helper'

describe API::ProjetsController do
  let(:projet) { FactoryGirl.create(:projet) }
  before(:each) {
    set_token_header(token)
    get :show, projet_id: projet.id
  }
  context 'avec un jeton invalide' do
    let(:token) { 'fake' }
    it "authentification invalide avec mauvais token" do
      expect(response.status).to eq(401)
      expect(response.content_type).to eq(Mime::JSON)
    end
  end

  context 'avec un jeton valide' do
    let(:token) { 'test' }
    it { expect(response.status).to eq(200) }
    it { expect(response.content_type).to eq(Mime::JSON) }
    it 'renvoie un json avec la bonne adresse' do
      projet_reponse = json(response.body)
      expect(projet_reponse[:adresse]).to eq(projet.adresse.description)
    end
  end
end
