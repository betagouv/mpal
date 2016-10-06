require 'rails_helper'
require 'support/mpal_helper'
require 'support/api_particulier_helper'
require 'support/api_ban_helper'

feature "choisir un opérateur" do
  scenario "déjà invité", pending: true do
    invitation = FactoryGirl.create(:invitation) 
    projet = invitation.projet
    operateur = invitation.intervenant
    projet.operateur = operateur
    projet.save

    visit projets_path(projet, jeton: invitation.token)

    within "#projet_#{projet.id}" do
      expect(page).to have_content(I18n.t("projets.statut.en_cours"))
    end

  end
end

