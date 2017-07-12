require 'rails_helper'
require 'support/mpal_features_helper'
require 'support/api_particulier_helper'
require 'support/api_ban_helper'

feature "Les information personnelles syntéthiques sont visibles" do
  let(:user)            { create :user }
  let(:projet)          { create(:projet, :prospect, :with_assigned_operateur, :with_invited_instructeur, :with_invited_pris, user: user, personne: personne, locked_at: Time.new(2001, 2, 3, 4, 5, 6)) }
  let(:personne)        { create :personne }
  let(:operateur)       { projet.operateur }
  let(:agent_operateur) { projet.agent_operateur }

  scenario "en tant que demandeur dont l’éligibilité est figée" do
    login_as user, scope: :user
    visit projet_path(projet)
    within '.personal-information' do
      expect(page).to have_content(projet.demandeur.fullname)
      expect(page).to have_content(projet.tel)
      expect(page).to have_content(projet.email)
      expect(page).to have_no_content("très modeste")
      expect(page).to have_content(I18n.t('projets.visualisation.occupants', count: projet.nb_total_occupants))
    end
    within '.personne' do
      expect(page).to have_content(personne.fullname)
      expect(page).to have_content(personne.tel)
      expect(page).to have_content(personne.email)
    end
  end

  scenario "en tant qu'intervenant" do
    login_as agent_operateur, scope: :agent
    visit dossier_path(projet)
    within '.personal-information' do
      expect(page).to have_content(projet.demandeur.fullname)
      expect(page).to have_content(projet.tel)
      expect(page).to have_content(projet.email)
      expect(page).to have_content("très modeste")
      expect(page).to have_content(I18n.t('projets.visualisation.occupants', count: projet.nb_total_occupants))
    end
  end
end
