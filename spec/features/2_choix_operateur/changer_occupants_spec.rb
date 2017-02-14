require 'rails_helper'
require 'support/mpal_helper'
require 'support/api_particulier_helper'
require 'support/api_ban_helper'

feature "Renseigner et modifier des occupants" do
  context "en tant que demandeur" do
    let(:projet)    { create(:projet, :prospect) }
    let!(:occupant) { create(:occupant, projet: projet) }

    scenario "je peux ajouter un occupant", pending: true do
      signin(projet.numero_fiscal, projet.reference_avis)
      visit etape1_recuperation_infos_demarrage_projet_path(projet)
      click_link I18n.t('projets.visualisation.lien_ajout_occupant')
      fill_in :occupant_nom,                  with: 'Marielle'
      fill_in :occupant_prenom,               with: 'Jean-Pierre'
      fill_in :occupant_date_de_naissance,    with: '20/05/2010'
      click_button I18n.t('occupants.nouveau.action')
      expect(page).to have_content('Jean-Pierre Marielle')
    end

    scenario "je peux modifier un occupant", pending: true do
      signin(projet.numero_fiscal, projet.reference_avis)
      Projet.last.demande = FactoryGirl.create(:demande)
      click_link I18n.t('projets.visualisation.modifier_liste_occupant')
      fill_in 'projet_nb_occupants_a_charge', with: 2
      click_button I18n.t('projets.composition_logement.edition.action')
      expect(page).to have_content('2 occupants à charge')
    end

    scenario "je peux supprimer un occupant", pending: true do
      skip
    end
  end
end
