require 'rails_helper'

describe MyCasController do
  context "en tant qu'agent non connecté" do
    scenario "je suis redirigé vers Clavis" do
      @request.env["devise.mapping"] = Devise.mappings[:agent]
      get :new
      expect(response).to redirect_to("#{ENV['CLAVIS_URL']}login?service=#{CGI.escape(agent_service_url)}")
    end
  end
end

