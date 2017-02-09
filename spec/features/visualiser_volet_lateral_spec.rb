require 'rails_helper'
require 'support/mpal_helper'
require 'support/api_particulier_helper'
require 'support/api_ban_helper'

feature "L'opérateur visualise les informations syntéthiques concernant le projet dans le volet gauche de la vue projet" do
  let(:projet) { create :projet }

  scenario "Les informations personnelles sont visibles" do
    signin(projet.numero_fiscal, projet.reference_avis)
    visit projet_path(projet)
    within '.personal-information' do
      expect(page).to have_content(projet.demandeur_principal.fullname)
      expect(page).to have_content(projet.tel)
      expect(page).to have_content(projet.email)
      expect(page).to have_content("très modeste")
      expect(page).to have_content(I18n.t('projets.visualisation.occupants', count: projet.nb_total_occupants))
    end
  end
end
