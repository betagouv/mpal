require 'rails_helper'
require 'support/api_particulier_helper'

describe SessionsController do
  let(:projet) { create :projet }
  let(:intervenant) { create :intervenant }
  let(:invitation) { create :invitation, intervenant: intervenant, projet: projet }

  # it "quand un demandeur se connecte avec succès il est redirigé vers la page projet" do
  #   expect(response).to redirect_to new_session_path
  # end
end
