require 'rails_helper'

feature "Démarrer un projet" do
  scenario "depuis la page d'accueil" do
    visit root_path
    click_on I18n.t('accueil.action')
    expect(page.current_path).to eq(new_session_path)
  end
end
