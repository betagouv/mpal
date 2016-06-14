require 'rails_helper'
require 'support/mpal_helper'
require 'support/api_particulier_helper'
require 'support/api_ban_helper'

feature "Invitation" do
  let(:projet) { FactoryGirl.create(:projet) }
  let!(:operateur) { FactoryGirl.create(:operateur, departements: [projet.departement]) }


  scenario "prise de contact avec un opérateur" do
    signin(projet.numero_fiscal, projet.reference_avis)
    click_link I18n.t('projets.visualisation.invitation_operateur')
    fill_in :projet_description, with: 'Je veux changer ma chaudière'
    fill_in :projet_email, with: 'martin@gmel.com'
    fill_in :projet_tel, with: '01 30 20 40 10'
    click_button I18n.t('invitations.nouvelle.action', operateur: operateur.raison_sociale)
    expect(page).to have_content(I18n.t('invitations.messages.succes', operateur: operateur.raison_sociale))
    expect(page).to have_content('martin@gmel.com')
  end

  scenario "prise de contact avec un opérateur sans laisser d'email" do
    signin(projet.numero_fiscal, projet.reference_avis)
    click_link I18n.t('projets.visualisation.invitation_operateur')
    fill_in :projet_description, with: 'Je veux changer ma chaudière'
    fill_in :projet_tel, with: '01 30 20 40 10'
    click_button I18n.t('invitations.nouvelle.action', operateur: operateur.raison_sociale)
    expect(page).to have_content(I18n.t('invitations.messages.erreur'))
    expect(page).to have_content(I18n.t('invitations.messages.email.obligatoire'))
  end
end
