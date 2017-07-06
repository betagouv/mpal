require 'rails_helper'
require 'support/mpal_features_helper'

feature "Administration des thèmes", skip: true do
  before do
    create :theme, libelle: "Autonomie"
    create :theme, libelle: "Autres travaux"
    create :theme, libelle: "Habiter mieux"
    authenticate_as_admin_with_token
  end

  scenario "je veux voir la liste" do
    visit admin_themes_path
    expect(page).to have_content("Autonomie")
    expect(page).to have_content("Autres travaux")
  end
end
