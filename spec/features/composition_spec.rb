require 'rails_helper'

feature "Invitation" do
  let(:projet) { FactoryGirl.create(:projet) }

  scenario "modification d'un occupant" do
    signin(projet.numero_fiscal, projet.reference_avis)
    click_link I18n.t('projets.visualisation.modifier_list_occupant')
    fill_in 'projet_nb_occupants_a_charge', with: 2
    click_button I18n.t('projets.composition_logement.edition.action')
    expect(page).to have_content('2 occupants à charge')
  end
end
