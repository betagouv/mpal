require 'rails_helper'
require 'support/mpal_helper'
require 'support/api_particulier_helper'

feature "En tant que demandeur, je peux m'engager avec un opérateur" do
  let(:projet)    { create(:projet, :with_invited_operateur) }
  let(:operateur) { projet.invited_operateur }

  scenario "je m'engage auprès d'un opérateur qui a été consulté" do
    signin(projet.numero_fiscal, projet.reference_avis)
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
