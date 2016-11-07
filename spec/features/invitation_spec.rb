require 'rails_helper'
require 'support/mpal_helper'
require 'support/api_particulier_helper'
require 'support/api_ban_helper'

feature "Invitation" do
  let(:projet) { FactoryGirl.create(:projet) }
  let!(:pris) { FactoryGirl.create(:intervenant, departements: [projet.departement], roles: [:pris]) }
  let!(:operateur) { FactoryGirl.create(:intervenant, departements: [projet.departement], roles: [:operateur]) }
  let(:invitation) { FactoryGirl.create(:invitation) }

  scenario "mise en relation par un pris entre un operateur et un demandeur" do
    invitation = FactoryGirl.create(:invitation, projet: projet, intervenant: pris)
    visit projet_path(id: invitation.projet, jeton: invitation.token)
    click_link 'Intervenants'
    within '.disponibles' do
      click_button I18n.t('projets.visualisation.mise_en_relation_intervenant')
    end
    expect(page).to have_content(I18n.t('invitations.messages.succes', intervenant: operateur.raison_sociale))
  end
end
