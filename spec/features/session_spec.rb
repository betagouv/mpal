require 'rails_helper'
require 'support/api_particulier_helper'

describe "identification", type: :feature do
  scenario "je démarre mon projet", focus: true do
    visit new_session_path
    fill_in :numero_fiscal, with: '12'
    fill_in :reference_avis, with: '15'
    click_button I18n.t('sessions.nouvelle.action')
    expect(page).to have_content("Martin")
  end
end

feature "Réinitialisation de la session" do
  let(:projet) { FactoryGirl.create(:projet) }
  let(:invitation) { FactoryGirl.create(:invitation) }

  scenario "je vois le lien pour se déconnecter s'il y a un projet et un message qui m'annonce que je me suis bien deconnecté(e)" do
    pending
    signin(projet.numero_fiscal, projet.reference_avis)
    visit projet_path(projet)
    expect(page).to have_content("Martin")
    expect(page).to have_link(I18n.t('sessions.lien_deconnexion'), href: '/deconnexion')
    click_link I18n.t('sessions.lien_deconnexion')
    expect(page).to have_content(I18n.t('sessions.confirmation_deconnexion'))
  end

  scenario "je peux me déconnecter si je consulte le projet en tant qu'intervenant via une invitation" do
    pending
    visit projet_path(invitation.projet, jeton: invitation.token)
    expect(page).to have_link(I18n.t('sessions.lien_deconnexion'), href: '/deconnexion')
    click_link I18n.t('sessions.lien_deconnexion')
    expect(page).to have_content(I18n.t('sessions.confirmation_deconnexion'))
  end

end
