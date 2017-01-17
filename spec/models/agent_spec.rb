require 'rails_helper'

describe Agent do
  describe 'validations' do
    let(:agent) { build :agent }
    it { expect(agent).to be_valid }
    it { is_expected.to validate_presence_of :nom }
    it { is_expected.to validate_presence_of :prenom }
    it { is_expected.to belong_to :intervenant }
  end

  describe '#cas_extra_attributes=' do
    firstname = 'Jean'
    lastname = 'Durand'
    service_id = 'someserviceid'
    let(:agent) { build :agent }
    let!(:intervenant) { create :intervenant, clavis_service_id: service_id }
    it {
      agent.cas_extra_attributes = { Prenom: firstname, Nom: lastname, ServiceId: service_id }
      expect(agent.prenom).to eq(firstname)
      expect(agent.nom).to eq(lastname)
      expect(agent.intervenant).to eq(intervenant)
    }
  end

  describe '#to_s' do
    let(:agent) { build :agent }
    it { expect(agent.to_s).to eq('Joelle Dupont') }
    it 'devrait ignorer les éléments vides' do
      agent.prenom = ' '
      expect(agent.to_s).to eq('Dupont')
    end
    it 'devrait éliminer les espaces inutiles' do
      agent.prenom = ' Jean'
      expect(agent.to_s).to eq('Jean Dupont')
    end
  end
end
