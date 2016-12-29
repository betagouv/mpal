require 'rails_helper'
require 'support/mpal_helper'
require 'support/api_particulier_helper'
require 'support/api_ban_helper'

feature "L'opérateur visualise les informations syntéthiques concernant le projet dans le volet gauche de la vue projet" do

  scenario "Les informations personnelles sont visibles " do
    signin(12,15)
    projet = Projet.last
    annee = 2015
    plafond = projet.preeligibilite(annee)
    visit projet_path(projet)
      within '.personal-information' do
        expect(page).to have_content(projet.demandeur_principal)
        expect(page).to have_content(projet.tel)
        expect(page).to have_content(projet.email)
        expect(page).to have_content("Très Modeste")
        expect(page).to have_content(projet.nb_total_occupants)
      end
  end
end
