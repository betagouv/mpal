require 'rails_helper'
require 'support/api_particulier_helper'
require 'support/api_ban_helper'
require 'support/mpal_helper'

describe EligibilitiesController do

  describe "#show" do
    let! (:projet) { create :projet, :prospect }

    before { authenticate_as_project projet.id }

    it "met à jour le locked_at quand la page eligibilité s'affiche" do
      get :show, projet_id: projet.id

      expect(projet.reload.locked_at).to eq Time.now
    end
  end

end
