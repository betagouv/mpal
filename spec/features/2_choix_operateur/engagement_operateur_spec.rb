require 'rails_helper'
require 'support/mpal_features_helper'
require 'support/api_particulier_helper'

feature "S'engager avec un opérateur :" do
  let(:user)      { create :user }
  let(:projet)    { create :projet, :prospect, :with_contacted_operateur, user: user, locked_at: Time.new(2001, 2, 3, 4, 5, 6) }
  let(:operateur) { projet.contacted_operateur }

  scenario "en tant que demandeur, je peux m'engager avec un opérateur" do
    login_as user, scope: :user
    visit projet_path(projet)
    click_link I18n.t('projets.visualisation.s_engager_avec_operateur')
    click_button I18n.t('projets.visualisation.engagement_action')

    expect(page.current_path).to eq(projet_path(projet))
    expect(page).to have_content(I18n.t('projets.intervenants.messages.succes_choix_intervenant'))
    expect(page).not_to have_content(I18n.t('projets.visualisation.s_engager_avec_operateur'))
    within '.projet-ope' do
      expect(page).to have_content(operateur.raison_sociale)
      expect(page).to have_content(I18n.t('projets.operateur_construit_proposition', operateur: operateur.raison_sociale))
    end
  end
end
