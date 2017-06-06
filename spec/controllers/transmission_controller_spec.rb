require 'rails_helper'
require 'support/mpal_helper'
require 'support/rod_helper'

describe TransmissionController do
  let(:projet) { create :projet, :proposition_proposee, :with_intervenants_disponibles }

  before(:each) { authenticate_as_project(projet.id) }

  describe "#create" do
    it "transmet pour instruction" do
      post :create, projet_id: projet.id

      projet.reload
      expect(response).to redirect_to projet_path(projet)
      expect(projet.statut.to_sym).to eq :transmis_pour_instruction
    end
  end
end

