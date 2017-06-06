require 'rails_helper'
require 'support/mpal_features_helper'
require 'support/api_particulier_helper'
require 'support/api_ban_helper'
require 'support/rod_helper'

feature "Choisir un mot de passe :" do
  let!(:projet) { create(:projet, :with_demandeur) }
  let!(:pris) {   create(:pris, departements: ["75"]) }

  context "en tant que demandeur" do
    scenario "je peux choisir mon mot de passe" do
      signin_for_new_projet
      visit new_user_registration_path
      expect(page).to have_content(I18n.t("demarrage_projet.users.section_name"))
      fill_in :user_email, with: "demandeur@exemple.fr"
      fill_in :user_password, with: "mon mot de passe"
      fill_in :user_password_confirmation, with: "mon mot de passe"
      click_button I18n.t('demarrage_projet.action')
      expect(page.current_path).to eq(projet_mise_en_relation_path(projet))
    end
  end
end

