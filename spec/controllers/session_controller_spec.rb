require 'rails_helper'
require 'support/api_particulier_helper'

describe SessionsController do
  let(:projet) { FactoryGirl.create(:projet)}
  # let(:session) { FactoryGirl.create(:session)}
  let(:intervenant) { FactoryGirl.create(:intervenant) }
  let(:invitation) { FactoryGirl.create(:invitation, intervenant: intervenant, projet: projet) }

  it "quand un intervenant se connecte avec son jeton, son role est celui d'un intervenant" do
    session[:jeton] = invitation.token
  end

  # it "quand un demandeur se connecte avec succès il est redirigé vers la page projet" do
  #   expect(response).to redirect_to new_session_path
  # end
end
