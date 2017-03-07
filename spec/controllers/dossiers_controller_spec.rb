require 'rails_helper'

describe DossiersController do
  context "en tant qu'agent, si je ne suis pas connecté" do
    it "je ne peux pas accéder à mon tableau de bord" do
      get :index
      expect(response).to redirect_to(new_agent_session_path)
    end

    it "je ne peux pas accéder à un dossier" do
      get :show, dossier_id: 42
      expect(response).to redirect_to(new_agent_session_path)
    end
  end
end
