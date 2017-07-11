require 'rails_helper'
require 'support/mpal_helper'
require 'support/opal_helper'

describe DossiersOpalController do
  let(:projet)            { create :projet, :transmis_pour_instruction, :with_payment_registry }
  let(:agent_instructeur) { create :agent, :instructeur, intervenant: projet.invited_instructeur }

  describe "#create" do
    context "en tant qu'agent instructeur" do
      before do
        authenticate_as_agent agent_instructeur
        post :create, dossier_id: projet.id
        projet.reload
      end

      it "transmet le dossier dans Opal" do
        expect(projet.opal_numero).to eq "09500840"
        expect(projet.statut).to eq "en_cours_d_instruction"
      end
    end
  end
end
