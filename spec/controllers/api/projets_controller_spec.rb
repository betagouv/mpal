require 'rails_helper'
require 'support/mpal_helper'
require 'support/api_particulier_helper'
require 'support/api_ban_helper'

describe API::ProjetsController do
  let(:projet) { FactoryGirl.create(:projet) }
  describe "GET 'show'" do
    before(:each) { get :show, id: projet.id }
    it { expect(response).to be_success }
  end
end
