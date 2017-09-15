require "rails_helper"
require "support/mpal_features_helper"

feature "J'ai accès à mes dossiers à partir de mon tableau de bord" do
  let(:projet)            { create :projet, :en_cours_d_instruction, :with_payment_registry }
  let(:demandeur)         { projet.demandeur_user }
  let(:agent_operateur)   { projet.agent_operateur }
  let(:agent_instructeur) { projet.agent_instructeur }

  context "en tant qu'opérateur" do

    before { login_as agent_operateur, scope: :agent }

    scenario "je peux ajouter, modifier, supprimer et envoyer pour validation une demande de paiement" do
      visit dossier_payment_registry_path(projet)

      # Ajout
      click_on I18n.t("payment_registry.add_payment")
      choose :avance
      fill_in I18n.t("payment.beneficiaire_question"), with: "SOLIHA"
      choose "Une personne morale"
      click_on I18n.t("payment.actions.create.label")

      click_on I18n.t("payment_registry.add_payment")
      choose :solde
      fill_in I18n.t("payment.beneficiaire_question"), with: "Emile Lévesque"
      choose "Une personne physique"
      click_on I18n.t("payment.actions.create.label")

      within ".test-entry-0" do
        expect(page).to have_content "Demande d’avance"
        expect(page).to have_content "En cours de montage"
        expect(page).to have_content I18n.t("payment_registry.legal_person", beneficiaire: "SOLIHA")
      end

      within ".test-entry-1" do
        expect(page).to have_content "Demande de solde"
        expect(page).to have_content "En cours de montage"
        expect(page).to have_content I18n.t("payment_registry.physical_person", beneficiaire: "Emile Lévesque")
      end

      # Modification
      within(".test-entry-0") { click_on I18n.t("payment.actions.modify.label") }
      choose :acompte
      fill_in I18n.t("payment.beneficiaire_question"), with: "Jean Louis"
      choose "Une personne physique"
      click_on I18n.t("payment.actions.modify.label")

      within ".test-entry-0" do
        expect(page).to have_content "Demande d’acompte"
        expect(page).to have_content "En cours de montage"
        expect(page).to have_content I18n.t("payment_registry.physical_person", beneficiaire: "Jean Louis")
      end

      # Suppression
      within(".test-entry-0") { click_on I18n.t("payment.actions.delete.label") }
      expect(page).to have_content I18n.t("payment.actions.delete.success")
      expect(page).not_to have_css ".test-entry-1"

      # Demande de validation
      within(".test-entry-0") { click_on I18n.t("payment.actions.ask_for_validation.label") }
      within ".test-entry-0" do
        expect(page).to have_content "Demande de solde"
        expect(page).to have_content "Proposée en attente de validation"
        expect(page).to have_content I18n.t("payment_registry.physical_person", beneficiaire: "Emile Lévesque")
      end
      expect(page).to have_content I18n.t("payment.actions.ask_for_validation.success")
    end
  end

  context "en tant qu'instructeur" do

    before do
      login_as agent_instructeur, scope: :agent
      create :payment, type_paiement: :avance, statut: :demande, action: :a_instruire, payment_registry: projet.payment_registry
      create :payment, type_paiement: :solde,  statut: :demande, action: :a_instruire, payment_registry: projet.payment_registry
    end

    scenario "je peux demander une modification sur un dossier, qui s'affiche ensuite juste après les dossiers nécessitant une action" do
      visit dossier_payment_registry_path(projet)

      # Demande de modification
      within(".test-entry-0") { click_on I18n.t("payment.actions.ask_for_modification.label") }
      expect(page).to have_content I18n.t("payment.actions.ask_for_modification.success", operateur: projet.operateur.raison_sociale)
      visit dossier_payment_registry_path(projet)
      within ".test-entry-1" do
        expect(page).to have_content "Demande d’avance"
        expect(page).to have_content "Déposée en attente de modification"
        expect(page).to have_content I18n.t("payment_registry.physical_person", beneficiaire: "")
      end
    end
  end

  context "en tant que demandeur" do

    before do
      login_as demandeur, scope: :user
      create :payment, type_paiement: :avance, statut: :propose, action: :a_valider, payment_registry: projet.payment_registry
      create :payment, type_paiement: :solde,  statut: :propose, action: :a_valider, payment_registry: projet.payment_registry
    end

    scenario "je peux demander une modification, qui s'affiche ensuite juste après les dossiers nécessitant une action" do
      visit dossier_payment_registry_path(projet)

      # Demande de modification
      within(".test-entry-0") { click_on I18n.t("payment.actions.ask_for_modification.label") }
      expect(page).to have_content I18n.t("payment.actions.ask_for_modification.success", operateur: projet.operateur.raison_sociale)
      visit dossier_payment_registry_path(projet)
      within ".test-entry-1" do
        expect(page).to have_content "Demande d’avance"
        expect(page).to have_content "Proposée en attente de modification"
        expect(page).to have_content I18n.t("payment_registry.physical_person", beneficiaire: "")
      end

      # Dépôt
      within(".test-entry-0") { click_on I18n.t("payment.actions.ask_for_instruction.label") }
      expect(page).to have_content I18n.t("payment.actions.ask_for_instruction.success", instructeur: projet.invited_instructeur.raison_sociale)
      visit dossier_payment_registry_path(projet)
      within ".test-entry-1" do
        expect(page).to have_content "Demande de solde"
        expect(page).to have_content "Déposée"
        expect(page).to have_content I18n.t("payment_registry.physical_person", beneficiaire: "")
      end
    end
  end
end
