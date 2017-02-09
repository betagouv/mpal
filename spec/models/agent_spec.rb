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
    let(:prenom) { 'Jean' }
    let(:nom) { 'Durand' }
    let(:service_id) { 'someserviceid' }
    let(:agent) { build :agent }
    let!(:intervenant) { create :intervenant, clavis_service_id: service_id }
    before { agent.cas_extra_attributes = { Prenom: prenom, Nom: nom, ServiceId: service_id } }
    it 'should translate successfully' do
      expect(agent.prenom).to eq(prenom)
      expect(agent.nom).to eq(nom)
      expect(agent.intervenant).to eq(intervenant)
    end
  end

  describe '#to_s' do
    let!(:agent) { build :agent }
    it { expect(agent.fullname).to eq('Joelle Dupont') }
    context 'supprime les espaces inutiles' do
      before {
        agent.prenom = ' Jean '
        agent.save!
      }
      it { expect(agent.fullname).to eq('Jean Dupont') }
    end
  end
end
