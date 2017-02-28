require 'rails_helper'
require 'support/mpal_helper'

feature "Accès à l’administration" do
  before { authenticate_as_admin_with_token }

  scenario "en tant que développeur je peux me connecter à l’administration" do
    visit admin_root_path
    expect(page.current_path).to eq(admin_root_path)
    expect(page).to have_content("Bonjour")
  end
end
