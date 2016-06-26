require 'rails_helper'
require 'support/mpal_helper'
require 'support/api_particulier_helper'
require 'support/api_ban_helper'

feature "intervenant" do
  let(:invitation) { FactoryGirl.create(:invitation) }
  let(:projet) { invitation.projet }
  let!(:operateur) { FactoryGirl.create(:intervenant, :operateur, departements: [ projet.departement ]) }

  scenario "visualisation d'un projet" do
    visit intervenant_projet_path(invitation.token)
    expect(page).to have_content(projet.adresse)
    within '.disponibles' do
      expect(page).to have_content(operateur.raison_sociale)
    end
  end
end
