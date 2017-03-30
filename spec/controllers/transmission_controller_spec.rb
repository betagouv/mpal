require 'rails_helper'
require 'support/mpal_helper'

describe TransmissionController do
  let(:projet) { create :projet, :proposition_proposee, :with_intervenants_disponibles, email: '' }

  before(:each) do
    authenticate_as_particulier(projet.numero_fiscal)
  end

  describe "#create" do
    it "transmet pour instruction" do
      post :create, projet_id: projet.id,
            projet: { email: 'lala@toto.com' }

      projet.reload
      expect(response).to redirect_to projet_path(projet)
      expect(projet.email).to eq 'lala@toto.com'
      expect(projet.statut.to_sym).to eq :transmis_pour_instruction
    end

    it "ne fait rien si l'email est invalide" do
      post :create, projet_id: projet.id,
            projet: { email: 'lalatoto.com' }

      projet.reload
      expect(response).to redirect_to projet_transmission_path(projet)
      expect(projet.email).to eq ''
      expect(projet.statut.to_sym).to eq :proposition_proposee
      expect(flash[:alert]).to eq I18n.t('projets.transmission.messages.validation_email')
    end

    it "ne fait rien si l'email est vide" do
      post :create, projet_id: projet.id,
           projet: { email: '' }

      projet.reload
      expect(response).to redirect_to projet_transmission_path(projet)
      expect(projet.email).to eq ''
      expect(projet.statut.to_sym).to eq :proposition_proposee
      expect(flash[:alert]).to eq I18n.t('projets.transmission.messages.validation_email_vide')
    end
  end
end
