require 'rails_helper'
require 'support/rod_helper'

RSpec.describe 'CAS authentication' do
  let(:service_id) { '1234' }
  let(:attributes) do
    {
      Nom: 'nom',
      Prenom: 'prenom',
      Id: '11111',
      ServiceId: service_id
    }
  end

  let(:ticket) do
    ticket = CASClient::ServiceTicket.new('CLAVIS-test', nil)
    ticket.extra_attributes = attributes
    ticket.success = true
    ticket.user = "testusername"
    ticket
  end

  context "Quand l'intervenant n'existe pas en base" do
    before { Fakeweb::Rod.register_intervenant }

    it "devrait créer un intervenant" do
      Agent.authenticate_with_cas_ticket(ticket)

      expect(Agent.last.intervenant).to be_truthy
    end

    it "devrait avoir toutes les informations du rod" do
      Agent.authenticate_with_cas_ticket(ticket)

      agent = Agent.last
      expect(agent.intervenant.raison_sociale).to eq(Fakeweb::Rod::FakeResponse[:raison_sociale])
    end
  end

  context "Quand l'intervenant est en base" do
    before { Fakeweb::Rod.register_intervenant }
    let(:intervenant) { create(:intervenant, clavis_service_id: service_id) }

    it "devrait être cet intervenant" do
      intervenant
      agent = Agent.authenticate_with_cas_ticket(ticket)

      expect(agent.intervenant.id).to eq(intervenant.id)
    end
  end
end
