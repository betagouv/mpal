require 'rails_helper'
require 'support/mpal_helper'
require 'support/api_particulier_helper'
require 'support/api_ban_helper'

feature "Invitation" do
  let(:invitation) { FactoryGirl.create(:invitation) }
  let(:projet) { FactoryGirl.create(:projet) }
  let!(:pris) { FactoryGirl.create(:intervenant, departements: [projet.departement], roles: [:pris]) }
  let!(:operateur) { FactoryGirl.create(:intervenant, departements: [projet.departement], roles: [:operateur]) }


  scenario "prise de contact avec un pris" do
    signin(projet.numero_fiscal, projet.reference_avis)
    click_link I18n.t('projets.visualisation.invitation_intervenant')
    fill_in :projet_description, with: 'Je veux changer ma chaudière'
    fill_in :projet_email, with: 'martin@gmel.com'
    fill_in :projet_tel, with: '01 30 20 40 10'
    click_button I18n.t('invitations.nouvelle.action', intervenant: pris.raison_sociale)
    expect(page).to have_content(I18n.t('invitations.messages.succes', intervenant: pris.raison_sociale))
    expect(page).to have_content('martin@gmel.com')
    expect(page).to have_css '.invites'
    expect(page).to have_content(I18n.t('evenements.invitation_intervenant', intervenant: pris.raison_sociale))
    expect(page).not_to have_content(I18n.t('evenements.invitation_intervenant', intervenant: operateur.raison_sociale))
  end

  scenario "prise de contact avec un pris sans laisser d'email" do
    signin(projet.numero_fiscal, projet.reference_avis)
    click_link I18n.t('projets.visualisation.invitation_intervenant')
    fill_in :projet_description, with: 'Je veux changer ma chaudière'
    fill_in :projet_tel, with: '01 30 20 40 10'
    click_button I18n.t('invitations.nouvelle.action', intervenant: pris.raison_sociale)
    expect(page).to have_content(I18n.t('invitations.messages.erreur'))
    expect(page).to have_content(I18n.t('invitations.messages.email.obligatoire'))
  end

  scenario "affichage d'un projet par un opérateur invité" do
    visit invitation_path(jeton_id: invitation.token)
    expect(page).to have_content(invitation.usager)
    expect(page).to have_content(invitation.adresse)
  end
end
