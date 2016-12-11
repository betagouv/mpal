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

  let!(:aide) { FactoryGirl.create(:aide, libelle:'Subvention ANAH') }
  let!(:subvention_anah) { FactoryGirl.create(:projet_aide, aide_id: aide.id, montant: 2305.10, projet: projet) }

  let!(:instructeur) { FactoryGirl.create(:intervenant, :instructeur, departements: [ projet.departement ]) }

  scenario "visualisation d'un projet par un pris" do
    pending
    visit projet_path(invitation.projet, jeton: invitation.token)
    expect(page).to have_content(projet.adresse)
    click_link 'Intervenants'
    within '.disponibles' do
    expect(page).to have_content(operateur.raison_sociale)
    end
  end

  context "en tant qu'operateur" do
    projet = FactoryGirl.create(:projet)
    operateur = FactoryGirl.create(:intervenant, :operateur)
    invit = FactoryGirl.create(:invitation, projet: projet, intervenant: operateur)
    projet.operateur = operateur
    projet.statut = :en_cours
    projet.save

    scenario "visualisation de la demande de travaux par l'operateur" do
      visit projet_path(projet, jeton: invit.token)
      click_link I18n.t('projets.visualisation.remplir_le_projet')
      expect(page).to have_content('Remplacement d\'une baignoire par une douche')
      expect(page).to have_content("Plâtrerie")
    end

    scenario "visualisation de la demande de financement par l'operateur" do
      visit projet_demande_path(projet, jeton: invit.token)
      expect(page).to have_content('Plan de financement')
      expect(page).to have_content(aide.libelle)
    end

    scenario "upload d'un document" do
      visit projet_demande_path(projet, jeton: invit.token)
      attach_file :fichier_document, Rails.root + "spec/fixtures/mapiece.txt"
      fill_in 'label_document', with: 'Titre de propriété'
      click_button(I18n.t('projets.demande.action_depot_document'))
      expect(page).to have_content(I18n.t('projets.demande.messages.succes_depot_document'))
      expect(page).to have_content('Titre de propriété')
      expect(projet.documents.count).to eq(1)
    end

    scenario "upload d'un document avec erreur" do
      visit projet_demande_path(projet, jeton: invit.token)
      attach_file :fichier_document, Rails.root + "spec/fixtures/mapiece.txt"
      click_button(I18n.t('projets.demande.action_depot_document'))
      expect(page).to have_content(I18n.t('projets.demande.messages.erreur_label_manquant'))
    end

    scenario "visualisation d'un document" do
      document = FactoryGirl.create(:document, projet: projet)
      visit projet_demande_path(projet, jeton: invit.token)
      expect(page).to have_link(document.label, href: document.fichier_url)
    end
  end

  scenario "accès à un projet à partir du tableau de bord" do
    projet_prospect = FactoryGirl.create(:projet, statut: :prospect)
    projet_en_cours = FactoryGirl.create(:projet, statut: :en_cours)
    invitation_prospect = FactoryGirl.create(:invitation, intervenant: operateur, projet: projet_prospect)
    invitation_en_cours = FactoryGirl.create(:invitation, intervenant: operateur, projet: projet_en_cours)

    visit projets_path(jeton: invitation_prospect.token)
    within "#projet_#{projet_prospect.id}" do
      expect(page).to have_content(I18n.t("prospect", scope: "projets.statut"))
      click_link projet_prospect.demandeur_principal
      expect(page).to have_content(projet_prospect.demandeur_principal)
    end

    visit projets_path(jeton: invitation_prospect.token)
    within "#projet_#{projet_en_cours.id}" do
      expect(page).to have_content(I18n.t("en_cours", scope: "projets.statut"))
      click_link projet_en_cours.demandeur_principal
      expect(page).to have_content(projet_en_cours.demandeur_principal)
    end
  end
end
