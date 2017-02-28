require 'rails_helper'
require 'support/mpal_helper'

feature "Administration des thèmes" do
  before { authenticate_as_admin_with_token }

  scenario "je veux voir la liste" do
    visit admin_themes_path
    expect(page).to have_content("Autonomie")
    expect(page).to have_content("Autres travaux")
    expect(page).to have_content("Habiter mieux")
  end
end
