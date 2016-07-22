require 'rails_helper'
require 'support/mpal_helper'
require 'support/api_particulier_helper'
require 'support/api_ban_helper'

feature "intervenant" do
  let(:invitation) { FactoryGirl.create(:invitation) }
  let(:projet) { invitation.projet }
  let!(:operateur) { FactoryGirl.create(:intervenant, :operateur, departements: [ projet.departement ]) }
  let(:mise_en_relation) { FactoryGirl.create(:mise_en_relation, projet: projet, intermediaire: invitation.intervenant) }
  let!(:chaudiere) { FactoryGirl.create(:prestation, libelle: 'Chaudière', projet: projet) }

  scenario "visualisation d'un projet par un pris" do
    visit projet_path(invitation.projet, jeton: invitation.token)
    expect(page).to have_content(projet.adresse)
    within '.disponibles' do
      expect(page).to have_content(operateur.raison_sociale)
    end
  end

  scenario "visualisation de la demande de financement par l'operateur" do
    visit projet_demande_path(mise_en_relation.projet, jeton: mise_en_relation.token)
    expect(page).to have_content('Prestations retenues')
    within '.prestations .retenues' do
      expect(page).to have_content(chaudiere.libelle)
    end
  end
end
