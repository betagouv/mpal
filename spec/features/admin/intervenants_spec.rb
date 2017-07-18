require 'rails_helper'
require 'support/mpal_features_helper'

feature "Administration des intervenants" do
  let!(:intervenant1) { create :operateur }
  let!(:intervenant2) { create :instructeur }
  let!(:intervenant3) { create :pris }
  before { authenticate_as_admin_with_token }

  scenario "en tant qu'administrateur je peux lister tous les intervenants du site", skip: true do
    visit admin_intervenants_path
    expect(page.current_path).to eq(admin_intervenants_path)
    expect(page).to have_content intervenant1.raison_sociale
    expect(page).to have_content intervenant2.raison_sociale
    expect(page).to have_content intervenant3.raison_sociale
  end
end
