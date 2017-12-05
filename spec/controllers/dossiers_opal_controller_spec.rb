require "rails_helper"
require "support/mpal_helper"
require "support/opal_helper"

describe DossiersOpalController do

  describe "#create" do
    let(:projet)            { create :projet, :transmis_pour_instruction, :statut_updated_date => Date.new(1991, 02, 04) }
    let(:agent_instructeur) { create :agent, :instructeur, intervenant: projet.invited_instructeur }

    context "en tant qu'agent instructeur" do
      before do
        authenticate_as_agent agent_instructeur
        post :create, params: { dossier_id: projet.id }
        projet.reload
      end

      it "transmet le dossier dans Opal" do
        expect(projet.opal_numero).to eq "09500840"
        expect(projet.statut).to eq "en_cours_d_instruction"
        expect(projet.statut_updated_date).to eq projet.updated_at
      end
    end
  end
end
