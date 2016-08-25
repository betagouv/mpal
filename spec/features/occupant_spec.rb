require 'rails_helper'
require 'support/mpal_helper'
require 'support/api_particulier_helper'
require 'support/api_ban_helper'

feature "Occupant" do
  let(:projet) { FactoryGirl.create(:projet) }
  let!(:occupant) { FactoryGirl.create(:occupant, projet: projet) }

  scenario "ajout d'un occupant" do
    signin(projet.numero_fiscal, projet.reference_avis)
    click_link I18n.t('projets.visualisation.lien_ajout_occupant')
    fill_in :occupant_nom,                  with: 'Marielle'
    fill_in :occupant_prenom,               with: 'Jean-Pierre'
    # fill_in :occupant_lien_demandeur,       with: '1'
    # fill_in :occupant_civilite,             with: 'mr'
    fill_in :occupant_date_de_naissance,    with: '20/05/2010'
    click_button I18n.t('occupants.nouveau.action')
    expect(page).to have_content('Jean-Pierre Marielle')
  end

  scenario "composition du logement" do
    signin(projet.numero_fiscal, projet.reference_avis)
    click_link I18n.t('projets.visualisation.modifier_liste_occupant')
    fill_in :projet_nb_occupants_a_charge, with: '3'
    click_button I18n.t('projets.composition_logement.edition.action')
  end

  # scenario "ajout d'un avis d'imposition" do
  #   signin(projet.numero_fiscal, projet.reference_avis)
  #   click_link I18n.t('projets.visualisation.modifier_liste_occupant')
  #   within "#occupant_#{occupant.id}" do
  #   click_link occupant.to_s
  #   end
  # end

end
