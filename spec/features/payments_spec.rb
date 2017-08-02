require "rails_helper"
require "support/mpal_features_helper"

feature "J'ai accès à mes dossiers depuis mon tableau de bord" do
  let(:projet) { create :projet, :en_cours_d_instruction, :with_payment_registry }

  context "en tant qu'opérateur" do
    let(:operateur)       { create :operateur }
    let(:agent_operateur) { create :agent, intervenant: operateur }

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

      within "#entry_0" do
        expect(page).to have_content "Demande d’avance"
        expect(page).to have_content "En cours de montage"
        expect(page).to have_content I18n.t("payment_registry.legal_person", beneficiaire: "SOLIHA")
      end

      within "#entry_1" do
        expect(page).to have_content "Demande de solde"
        expect(page).to have_content "En cours de montage"
        expect(page).to have_content I18n.t("payment_registry.physical_person", beneficiaire: "Emile Lévesque")
      end

      # Modification
      within("#entry_0") { click_on I18n.t("payment.actions.modify.label") }
      choose :acompte
      fill_in I18n.t("payment.beneficiaire_question"), with: "Jean Louis"
      choose "Une personne physique"
      click_on I18n.t("payment.actions.modify.label")

      within "#entry_0" do
        expect(page).to have_content "Demande d’acompte"
        expect(page).to have_content "En cours de montage"
        expect(page).to have_content I18n.t("payment_registry.physical_person", beneficiaire: "Jean Louis")
      end

      # Suppression
      within("#entry_0") { click_on I18n.t("payment.actions.delete.label") }
      expect(page).to have_content I18n.t("payment.actions.delete.success")
      expect(page).not_to have_css "#entry_1"

      # Demande de validation
      within("#entry_0") { click_on I18n.t("payment.actions.ask_for_validation.label") }
      within "#entry_0" do
        expect(page).to have_content "Demande de solde"
        expect(page).to have_content "Proposée en attente de validation"
        expect(page).to have_content I18n.t("payment_registry.physical_person", beneficiaire: "Emile Lévesque")
      end
      expect(page).to have_content I18n.t("payment.actions.ask_for_validation.success")
    end
  end

  context "en tant qu'instructeur" do
    let(:instructeur)       { create :instructeur }
    let(:agent_instructeur) { create :agent, intervenant: instructeur }

    before do
      login_as agent_instructeur, scope: :agent
      create :payment, type_paiement: :avance, statut: :demande, action: :a_instruire, payment_registry: projet.payment_registry
      create :payment, type_paiement: :solde,  statut: :demande, action: :a_instruire, payment_registry: projet.payment_registry
    end

    scenario "je peux demander une modification" do
      visit dossier_payment_registry_path(projet)

      # Demande de modification
      within("#entry_0") { click_on I18n.t("payment.actions.ask_for_modification.label") }
      within "#entry_0" do
        expect(page).to have_content "Demande d’avance"
        expect(page).to have_content "Déposée en attente de modification"
        expect(page).to have_content I18n.t("payment_registry.physical_person", beneficiaire: "")
      end
      expect(page).to have_content I18n.t("payment.actions.ask_for_modification.success", operateur: projet.operateur.raison_sociale)
    end
  end

  context "en tant que demandeur" do
    let(:user) { create :user }

    before do
      login_as user, scope: :user
      projet.update_attribute :user, user
      create :payment, type_paiement: :avance, statut: :propose, action: :a_valider, payment_registry: projet.payment_registry
      create :payment, type_paiement: :solde,  statut: :propose, action: :a_valider, payment_registry: projet.payment_registry
    end

    scenario "je peux demander une modification" do
      visit dossier_payment_registry_path(projet)

      # Demande de modification
      within("#entry_0") { click_on I18n.t("payment.actions.ask_for_modification.label") }
      within "#entry_0" do
        expect(page).to have_content "Demande d’avance"
        expect(page).to have_content "Proposée en attente de modification"
        expect(page).to have_content I18n.t("payment_registry.physical_person", beneficiaire: "")
      end
      expect(page).to have_content I18n.t("payment.actions.ask_for_modification.success", operateur: projet.operateur.raison_sociale)

      # Dépôt
      within("#entry_1") { click_on I18n.t("payment.actions.ask_for_instruction.label") }
      within "#entry_1" do
        expect(page).to have_content "Demande de solde"
        expect(page).to have_content "Déposée"
        expect(page).to have_content I18n.t("payment_registry.physical_person", beneficiaire: "")
      end
      expect(page).to have_content I18n.t("payment.actions.ask_for_instruction.success", instructeur: projet.invited_instructeur.raison_sociale)
    end
  end
end
