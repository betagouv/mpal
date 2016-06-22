require 'rails_helper'
require 'support/mpal_helper'
require 'support/api_particulier_helper'
require 'support/api_ban_helper'

feature "Occupant" do
  let(:projet) { FactoryGirl.create(:projet) }

  scenario "ajout d'un occupant", pending: true do
    signin(projet.numero_fiscal, projet.reference_avis)
    click_link I18n.t('projets.visualisation.lien_ajout_occupant')
    fill_in :occupant_nom, with: 'Marielle'
    fill_in :occupant_prenom, with: 'Jean-Pierre'
    fill_in :occupant_lien_demandeur, with: 'enfant'
    fill_in :occupant_date_de_naissance, with: '20/05/2010'
    click_button I18n.t('occupants.nouveau.action')
    expect(page).to have_content('Jean-Pierre Marielle')
  end
end
