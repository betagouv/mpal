require 'rails_helper'

describe Agent do
  let(:agent) { FactoryGirl.build(:agent) }
  it { expect(FactoryGirl.build(:agent)).to be_valid }

  it { is_expected.to validate_presence_of(:nom) }
  it { is_expected.to validate_presence_of(:prenom) }
  it { is_expected.to belong_to(:intervenant) }

  describe 'to_s' do
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
