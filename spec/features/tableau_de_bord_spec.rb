require 'rails_helper'
require 'support/mpal_features_helper'
require 'support/api_particulier_helper'
require 'support/api_ban_helper'

feature "J'ai accès à mes dossiers depuis mon tableau de bord" do
  let(:projet)      { create(:projet, :en_cours_d_instruction, :with_invited_pris) }
  let(:operateur)   { projet.operateur }
  let(:instructeur) { projet.invited_instructeur }
  let(:pris)        { projet.invited_pris }
  let(:agent_operateur)   { projet.agent_operateur}
  let(:agent_instructeur) { projet.agent_instructeur}
  let(:agent_pris)        { create :agent, :pris, intervenant: pris}

  before do
    login_as current_agent, scope: :agent
  end

  context "en tant qu'opérateur" do
    let(:current_agent) { agent_operateur }

    scenario "j'ai accès au tableau de bord avec toutes les informations disponibles" do
      visit dossiers_path
      within "#projet_#{projet.id}" do
        expect(page).to have_content(projet.numero_plateforme)
        expect(page).to have_content(projet.opal_numero)
        expect(page).to have_content(projet.demandeur_principal.fullname)
        expect(page).to have_content(projet.adresse.region)
        expect(page).to have_css('td.departement', text: projet.adresse.departement)
        expect(page).to have_content(projet.adresse.ville)
        expect(page).to have_content(projet.agent_instructeur.intervenant.raison_sociale)
        expect(page).to have_content(projet.agent_instructeur.fullname)
        #TODO Theme
        expect(page).to have_content(projet.agent_operateur.intervenant.raison_sociale)
        expect(page).to have_content(projet.agent_operateur.fullname)
        expect(page).to have_content(I18n.t("projets.statut.en_cours_d_instruction"))
        #TODO Update Status At
      end
    end

    scenario "je peux accéder à un dossier à partir du tableau de bord" do
      visit dossiers_path
      click_link projet.numero_plateforme
      expect(page.current_path).to eq(dossier_path(projet))
      expect(page).to have_content(projet.demandeur_principal.fullname)
    end

    scenario "je ne peux pas accéder au dossier Opal" do
      visit dossiers_path
      expect(page).not_to have_link(projet.opal_numero, href: dossier_opal_url(projet.opal_numero))
    end
  end

  context "en tant qu'instructeur" do
    let(:current_agent) { agent_instructeur }

    # Attention les instructeurs voient tous les dossiers ! En attente de la règle métier
    scenario "j'ai accès au tableau de bord avec les informations disponibles pour les instructeurs" do
      visit dossiers_path
      within "#projet_#{projet.id}" do
        expect(page).to     have_content(projet.numero_plateforme)
        expect(page).to     have_content(projet.opal_numero)
        expect(page).to     have_content(projet.demandeur_principal.fullname)
        expect(page).not_to have_content(projet.adresse.region)
        expect(page).not_to have_css('td.departement')
        expect(page).to     have_content(projet.adresse.ville)
        expect(page).to     have_content(projet.agent_instructeur.intervenant.raison_sociale)
        expect(page).to     have_content(projet.agent_instructeur.fullname)
        #TODO Themes
        expect(page).to     have_content(projet.agent_operateur.intervenant.raison_sociale)
        expect(page).to     have_content(projet.agent_operateur.fullname)
        expect(page).to     have_content(I18n.t("projets.statut.en_cours_d_instruction"))
        #TODO Update Status At
      end
    end

    scenario "je peux accéder à un dossier à partir du tableau de bord" do
      visit dossiers_path
      click_link projet.numero_plateforme
      expect(page.current_path).to eq(dossier_path(projet))
      expect(page).to have_content(projet.demandeur_principal.fullname)
    end

    scenario "je peux accéder au dossier Opal" do
      visit dossiers_path
      expect(page).to have_link(projet.opal_numero, href: dossier_opal_url(projet.opal_numero))
    end
  end

  context "en tant que PRIS" do
    let(:current_agent) { agent_pris }

    # Attention les PRIS voient tous les dossiers ! En attente de la règle métier
    scenario "j'ai accès au tableau de bord avec toutes les informations disponibles pour les PRIS" do
      visit dossiers_path
      within "#projet_#{projet.id}" do
        expect(page).to     have_content(projet.plateforme_id)
        expect(page).not_to have_content(projet.opal_numero)
        expect(page).to     have_content(projet.demandeur_principal.fullname)
        expect(page).not_to have_content(projet.adresse.region)
        expect(page).not_to have_css('td.departement')
        expect(page).to     have_content(projet.adresse.ville)
        expect(page).to     have_content(projet.agent_instructeur.intervenant.raison_sociale)
        expect(page).not_to have_content(projet.agent_instructeur.fullname)
        #TODO Themes
        expect(page).to     have_content(projet.agent_operateur.intervenant.raison_sociale)
        expect(page).not_to have_content(projet.agent_operateur.fullname)
        expect(page).to     have_content(I18n.t("projets.statut.en_cours_d_instruction"))
        #TODO Update Status At
      end
    end

    scenario "je peux accéder à un dossier à partir du tableau de bord" do
      visit dossiers_path
      click_link projet.numero_plateforme
      expect(page.current_path).to eq(dossier_path(projet))
      expect(page).to have_content(projet.demandeur_principal.fullname)
    end
  end
end
