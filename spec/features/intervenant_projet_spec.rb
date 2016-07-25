require 'rails_helper'
require 'support/mpal_helper'
require 'support/api_particulier_helper'
require 'support/api_ban_helper'

feature "intervenant" do
  let(:invitation) { FactoryGirl.create(:invitation) }
  let(:projet) { invitation.projet }
  let!(:operateur) { FactoryGirl.create(:intervenant, :operateur, departements: [ projet.departement ]) }
  let(:mise_en_relation) { FactoryGirl.create(:mise_en_relation, projet: projet, intermediaire: invitation.intervenant) }
  let!(:chaudiere_s) { FactoryGirl.create(:prestation, libelle: 'Chaudière', scenario: :souhaite, projet: projet) }
  let!(:chaudiere_r) { FactoryGirl.create(:prestation, libelle: 'Chaudière', scenario: :retenu, projet: projet) }
  let!(:production_ecs_r) { FactoryGirl.create(:prestation, libelle: 'Production ECS', scenario: :retenu, projet: projet) }
  let!(:carrelage_s) { FactoryGirl.create(:prestation, libelle: 'Carrelage', scenario: :souhaite, projet: projet) }
  let!(:chaudiere_p) { FactoryGirl.create(:prestation, libelle: 'Chaudière', scenario: :preconise, projet: projet) }
  let!(:production_ecs_p) { FactoryGirl.create(:prestation, libelle: 'Production ECS', scenario: :preconise, projet: projet) }

  let!(:subvention_cd95) { FactoryGirl.create(:subvention, libelle:'CD95 - Aide amélioration habitat privé', montant: 2305.10, projet: projet) }
  let!(:subvention_anah) { FactoryGirl.create(:subvention, libelle:'ANAH - Habiter mieux', montant: 2305.10, projet: projet) }

  scenario "visualisation d'un projet par un pris" do
    visit projet_path(invitation.projet, jeton: invitation.token)
    expect(page).to have_content(projet.adresse)
    within '.disponibles' do
      expect(page).to have_content(operateur.raison_sociale)
    end
  end

  scenario "visualisation de la demande de travaux par l'operateur" do
    visit projet_demande_path(mise_en_relation.projet, jeton: mise_en_relation.token)
    expect(page).to have_content('Prestations retenues')
    within '.prestations .retenu' do
      expect(page).to have_content(chaudiere_r.libelle)
      expect(page).to have_content(production_ecs_r.libelle)
    end
    within '.prestations .souhaite' do
      expect(page).to have_content(chaudiere_s.libelle)
      expect(page).to have_content(carrelage_s.libelle)
    end
    within '.prestations .preconise' do
      expect(page).to have_content(chaudiere_p.libelle)
      expect(page).to have_content(production_ecs_p.libelle)
    end
  end

  scenario "visualisation de la demande de financement par l'operateur" do
    visit projet_demande_path(mise_en_relation.projet, jeton: mise_en_relation.token)
    expect(page).to have_content('Plan de financement')
    within ".subventions" do
      expect(page).to have_content(subvention_cd95.libelle)
    end
  end
end
