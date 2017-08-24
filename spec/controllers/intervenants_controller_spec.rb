require 'rails_helper'
require 'support/api_particulier_helper'
require 'support/api_ban_helper'
require 'support/mpal_helper'

describe IntervenantsController do
  describe "#index" do
    let(:user)                { create :user }
    let(:projet_with_user)    { create :projet, :en_cours, :with_assigned_operateur, user: user, locked_at: Time.new(1789, 7, 14, 16, 0, 0) }
    let(:projet_without_user) { create :projet, :prospect }
    let(:agent_operateur)     { projet_with_user.agent_operateur }

    context "quand je suis un agent" do
      it "je peux voir mes contacts si je suis agent du projet" do
        authenticate_as_agent(agent_operateur)
        get :index, dossier_id: projet_with_user.id
        expect(response).to render_template(:index)
      end
    end

    context "quand je suis un demandeur" do
      it "je peux voir mes contacts si j'ai un projet et au moins un agent associé" do
        authenticate_as_user(user)
        get :index, projet_id: projet_with_user.id
        expect(response).to render_template(:index)
      end

      it "je ne peux pas voir les contacts sinon" do
        authenticate_as_project projet_without_user.id
        get :index, projet_id: projet_without_user.id
        expect(response).not_to render_template(:index)
      end
    end
  end
end
