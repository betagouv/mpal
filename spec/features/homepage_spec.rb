require 'rails_helper'

describe "Homepage", type: :feature do
  scenario "affiche une presentation de MPAL" do
    visit root_path
    expect(page).to have_link(I18n.t('welcome.cta'))
  end
end
