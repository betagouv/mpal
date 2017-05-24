require 'rails_helper'
require 'support/mpal_features_helper'
require 'support/api_particulier_helper'
require 'support/api_ban_helper'

feature "Les informations légales concernant la plateforme sont disponibles" do
  let(:projet) { create :projet, :prospect }

  context "en tant que visiteur" do
    scenario "je peux consulter les mentions légales" do
      visit root_path(projet)
      click_link I18n.t('menu.legal')
      expect(page.current_path).to eq(informations_legal_path)
    end
  end

  context "en tant que demandeur" do
    scenario "je peux consulter les mentions légales" do
      signin(projet.numero_fiscal, projet.reference_avis)
      click_link I18n.t('menu.legal')
      expect(page.current_path).to eq(informations_legal_path)
    end
  end
end

