require 'rails_helper'
require 'support/mpal_features_helper'
require 'support/api_particulier_helper'
require 'support/api_ban_helper'

feature "Modifier les occupants" do
  context "en tant que demandeur" do
    let(:projet)    { create(:projet, :prospect) }
    let!(:occupant) { create(:occupant, projet: projet) }

    scenario "je peux modifier les occupants", pending: true do
      signin(projet.numero_fiscal, projet.reference_avis)
      Projet.last.demande = FactoryGirl.create(:demande)
      click_link I18n.t('projets.visualisation.modifier_liste_occupant')
      click_button I18n.t('projets.composition_logement.edition.action')
      expect(page).to have_content('2 occupants à charge')
    end
  end
end
