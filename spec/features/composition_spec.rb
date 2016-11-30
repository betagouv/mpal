require 'rails_helper'

feature "Invitation" do

  scenario "modification d'un occupant" do
    signin(12, 15)
    Projet.last.demande = FactoryGirl.create(:demande)
    click_link I18n.t('projets.visualisation.modifier_liste_occupant')
    fill_in 'projet_nb_occupants_a_charge', with: 2
    click_button I18n.t('projets.composition_logement.edition.action')
    expect(page).to have_content('2 occupants à charge')
  end
end
