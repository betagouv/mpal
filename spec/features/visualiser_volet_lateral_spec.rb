require 'rails_helper'
require 'support/mpal_features_helper'
require 'support/api_particulier_helper'
require 'support/api_ban_helper'

feature "Les information personnelles syntéthiques sont visibles" do
  let(:projet)          { create :projet }
  let(:operateur)       { create :operateur, departements: [projet.departement] }
  let(:agent_operateur) { create :agent, intervenant: operateur }
  let!(:invitation)     { create :invitation, intervenant: operateur, projet: projet }

  scenario "en tant que demandeur" do
    signin(projet.numero_fiscal, projet.reference_avis)
    visit projet_path(projet)
    within '.personal-information' do
      expect(page).to have_content(projet.demandeur_principal.fullname)
      expect(page).to have_content(projet.tel)
      expect(page).to have_content(projet.email)
      expect(page).to have_no_content("très modeste")
      expect(page).to have_content(I18n.t('projets.visualisation.occupants', count: projet.nb_total_occupants))
    end
  end

  scenario "en tant qu'intervenant" do
    login_as agent_operateur, scope: :agent
    visit dossier_path(projet)
    within '.personal-information' do
      expect(page).to have_content(projet.demandeur_principal.fullname)
      expect(page).to have_content(projet.tel)
      expect(page).to have_content(projet.email)
      expect(page).to have_content("très modeste")
      expect(page).to have_content(I18n.t('projets.visualisation.occupants', count: projet.nb_total_occupants))
    end
  end
end
