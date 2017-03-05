require 'rails_helper'
require 'support/opal_helper'

describe Opal do
  subject { Opal.new(OpalClient) }

  describe "#creer_dossier" do
    let(:projet) {            create :projet }
    let(:instructeur) {       create :instructeur }
    let(:agent_instructeur) { create :agent, intervenant: instructeur }

    it do
      subject.creer_dossier(projet, agent_instructeur)
      expect(projet.opal_id).to eq('959496')
      expect(projet.opal_numero).to eq('09500840')
      expect(projet.statut).to eq('en_cours_d_instruction')
      expect(projet.agent_instructeur).to eq(agent_instructeur)
    end
  end
end

