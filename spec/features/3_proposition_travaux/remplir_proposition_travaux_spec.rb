require 'rails_helper'
require 'support/mpal_helper'
require 'support/api_particulier_helper'
require 'support/api_ban_helper'

feature "remplir la proposition de travaux" do
  let(:projet) {            create :projet, :en_cours }
  let!(:instructeur) {      create :instructeur, departements: [projet.departement] }
  let!(:pris) {             create :pris,        departements: [projet.departement] }
  let!(:operateur) {        create :operateur,   departements: [projet.departement] }
  let!(:invitation) {       create :invitation, intervenant: operateur, projet: projet }
  let(:mise_en_relation) {  create :mise_en_relation, projet: projet, intermediaire: invitation.intervenant }
  let!(:chaudiere_s) {      create :prestation, libelle: 'Chaudière',      scenario: :souhaite,  projet: projet }
  let!(:chaudiere_r) {      create :prestation, libelle: 'Chaudière',      scenario: :retenu,    projet: projet }
  let!(:production_ecs_r) { create :prestation, libelle: 'Production ECS', scenario: :retenu,    projet: projet }
  let!(:carrelage_s) {      create :prestation, libelle: 'Carrelage',      scenario: :souhaite,  projet: projet }
  let!(:chaudiere_p) {      create :prestation, libelle: 'Chaudière',      scenario: :preconise, projet: projet }
  let!(:production_ecs_p) { create :prestation, libelle: 'Production ECS', scenario: :preconise, projet: projet }
  let!(:aide) {             create :aide, libelle: 'Subvention ANAH' }
  let!(:subvention_anah) {  create :projet_aide, aide_id: aide.id, montant: 2305.10, projet: projet }
  let(:agent_instructeur) { create :agent, intervenant: instructeur }
  let(:agent_pris) {        create :agent, intervenant: pris }
  let(:agent_operateur) {   create :agent, intervenant: operateur }

  context "en tant qu'opérateur" do
    let(:document) { create :document, projet: projet }
    before { login_as agent_operateur, scope: :agent }

    scenario "visualisation de la demande de travaux" do
      visit dossier_path(projet)
      click_link I18n.t('projets.visualisation.affecter_et_remplir_le_projet')
      expect(page).to have_content("Remplacement d'une baignoire par une douche")
      expect(page).to have_content("Plâtrerie")
    end

    scenario "modification de la demande" do
      visit dossier_demande_path(projet)
      fill_in 'projet_surface_habitable', with: '42'
      click_on 'Enregistrer cette proposition'
      expect(page.current_path).to eq(dossier_path(projet))
      expect(page).to have_content('42')
    end

    scenario "visualisation de la demande de financement" do
      visit dossier_demande_path(projet)
      expect(page).to have_content('Plan de financement prévisionnel')
      expect(page).to have_content(aide.libelle)
    end

    scenario "upload d'un document sans label" do
      visit dossier_demande_path(projet)
      attach_file :fichier_document, Rails.root + "spec/fixtures/Ma pièce jointe.txt"
      fill_in 'label_document', with: ''
      click_button(I18n.t('projets.demande.action_depot_document'))

      expect(projet.documents.count).to eq(1)
      expect(page).to have_content(I18n.t('projets.demande.messages.succes_depot_document'))
      expect(page).to have_link('Ma_pi_ce_jointe.txt', href: "/uploads/projets/#{projet.id}/Ma_pi_ce_jointe.txt")
    end

    scenario "upload d'un document avec un label" do
      visit dossier_demande_path(projet)
      attach_file :fichier_document, Rails.root + "spec/fixtures/Ma pièce jointe.txt"
      fill_in 'label_document', with: 'Titre de propriété'
      click_button(I18n.t('projets.demande.action_depot_document'))

      expect(projet.documents.count).to eq(1)
      expect(page).to have_content(I18n.t('projets.demande.messages.succes_depot_document'))
      expect(page).to have_link('Titre de propriété', href: "/uploads/projets/#{projet.id}/Ma_pi_ce_jointe.txt")
    end

    scenario "upload d'un document avec erreur" do
      visit dossier_demande_path(projet)
      click_button(I18n.t('projets.demande.action_depot_document'))

      expect(page).to have_content(I18n.t('projets.demande.messages.erreur_depot_document'))
    end
  end

  # TODO: déplacer ce test ailleurs
  context "projet prospect" do
    let!(:projet_prospect) {     create :projet, :prospect }
    let!(:invitation_prospect) { create :invitation, intervenant: operateur, projet: projet_prospect }
    before { login_as agent_operateur, scope: :agent }

    scenario "accès à un projet à partir du tableau de bord" do
      visit dossiers_path
      within "#projet_#{projet_prospect.id}" do
        expect(page).to have_content(I18n.t("prospect", scope: "projets.statut"))
        click_link projet_prospect.demandeur_principal
        expect(page).to have_content(projet_prospect.demandeur_principal)
      end

      visit dossiers_path
      within "#projet_#{projet.id}" do
        expect(page).to have_content(I18n.t("en_cours", scope: "projets.statut"))
        click_link projet.demandeur_principal
        expect(page).to have_content(projet.demandeur_principal)
      end
    end
  end
end
