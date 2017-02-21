require 'rails_helper'
require 'support/mpal_helper'

describe Admin::BaseController do
  controller do
    def index
      render text: "index called"
    end
  end

  describe "GET #index" do
    context "si non authentifié," do
      it "redirige vers la page de login" do
        get :index
        expect(response).to redirect_to new_agent_session_path
      end
    end

    context "si authentifié par clavis" do
      let(:agent) { create :agent }
      before { authenticate_with_agent agent }

      context "avec un agent non admin," do
        it "redirige vers " do
          get :index
          expect(response).to redirect_to dossiers_path
        end
      end

      context "avec un agent admin," do
        before { agent.admin = true }

        it "affiche la page" do
          get :index
          expect(response.body).to eq "index called"
        end
      end
    end

    context "si authentifié par token," do
      before { authenticate_with_admin_token }

      it "affiche la page" do
        get :index
        expect(response.body).to eq "index called"
      end
    end
  end
end
