require 'rails_helper'
require 'support/api_particulier_helper'
require 'support/mpal_helper'

describe "identification", type: :feature do
  scenario "je démarre mon projet", focus: true do
    signin(12,15)
    expect(page).to have_content("Martin")
  end

  scenario "je dois cocher la case des engagements pour pouvoir me connecter" do
    skip
    visit new_session_path
    fill_in :numero_fiscal, with: '12'
    fill_in :reference_avis, with: '15'
    check 'autorisation'
    sleep 1
    # Piste : capybara clique sur le bouton se connecter avant que le js ai activé le bouton...
    # field_labeled('autorisation', disabled: false)
    # find_field I18n.t('sessions.nouvelle.action'), disabled: false
    # click_on I18n.t('sessions.nouvelle.action')
  end
end

feature "Réinitialisation de la session" do
  let(:projet) {          create :projet }
  let(:invitation) {      create :invitation }
  let(:operateur) {       create :operateur, departements: [projet.departement] }
  let(:agent_operateur) { create :agent, intervenant: operateur }

  context "en tant que demandeur" do
    scenario "je vois le lien pour se déconnecter s'il y a un projet et un message qui m'annonce que je me suis bien deconnecté(e)" do
      signin(projet.numero_fiscal, projet.reference_avis)
      visit projet_path(projet)
      expect(page).to have_content("Martin")
      expect(page).to have_link(I18n.t('sessions.lien_deconnexion'))
      click_link I18n.t('sessions.lien_deconnexion')
      expect(page).to have_content(I18n.t('sessions.confirmation_deconnexion'))
    end
  end

  context "en tant qu'intervenant" do
    before { login_as agent_operateur, scope: :agent }
    scenario "j'ai un bouton pour me déconnecter" do
      visit dossier_path(invitation.projet)
      expect(page).to have_link(I18n.t('sessions.lien_deconnexion'))
    end
  end

  context "en tant qu'intervenant" do
    scenario "j'ai une notification de deconnexion" do
      visit agents_signed_out_path
      expect(page).to have_content(I18n.t('sessions.confirmation_deconnexion_clavis'))
    end
  end
end
