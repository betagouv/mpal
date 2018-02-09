require 'rails_helper'
require 'support/mpal_features_helper'
require 'support/api_particulier_helper'
require 'support/api_ban_helper'
require 'support/rod_helper'

feature "J'ai accès à mes dossiers depuis mon tableau de bord" do
  before do
    Fakeweb::Rod.list_department_intervenants_helper
    login_as current_agent, scope: :agent
  end

  context "en tant que siège" do
    let(:siege)         { create :siege }
    let(:current_agent) { create :agent, :siege, intervenant: siege }
    let(:projet_34)     { create :projet, :en_cours, email: "prenom.nom1@site.com" }
    let(:projet_01)     { create :projet, :proposition_proposee, email: "prenom.nom2@site.com" }
    let(:projet_56)     { create :projet, :en_cours_d_instruction, email: "prenom.nom3@site.com" }
    let(:projet_blank)  { create :projet }

    before do
      projet_34.adresse.update(departement: "34")
      projet_01.adresse.update(departement: "01")
      projet_56.adresse.update(departement: "56")
    end

    scenario "je vois absolument tous les dossiers France avec un demandeur" do
      visit dossiers_path

      expect(page).to have_content(projet_34.numero_plateforme)
      expect(page).to have_content(projet_34.opal_numero)
      expect(page).to have_content(projet_34.demandeur.fullname)
      expect(page).to have_content(projet_34.adresse.ville)
      expect(page).to have_content(projet_34.adresse.code_postal)
      expect(projet_34.agent_instructeur).to be_nil
      expect(projet_34.agent_instructeur).to be_nil
      # #TODO Theme
      expect(projet_34.agent_operateur).to be_nil
      expect(projet_34.agent_operateur).to be_nil
      expect(page).to have_content(I18n.t("projets.statut.en_cours_de_montage"))
      #TODO Update Status At

      expect(page).to have_content(projet_01.numero_plateforme)
      expect(page).to have_content(projet_01.opal_numero)
      expect(page).to have_content(projet_01.demandeur.fullname)
      expect(page).to have_content(projet_34.adresse.ville)
      expect(page).to have_content(projet_34.adresse.code_postal)
      expect(projet_01.agent_instructeur).to be_nil
      expect(projet_01.agent_instructeur).to be_nil
      # #TODO Theme
      expect(page).to have_content(projet_01.agent_operateur.intervenant.raison_sociale)
      expect(page).to have_content(projet_01.agent_operateur.fullname)
      expect(page).to have_content(I18n.t("projets.statut.en_cours_de_montage"))
      #TODO Update Status At

      expect(page).to have_content(projet_56.numero_plateforme)
      expect(page).to have_content(projet_56.opal_numero)
      expect(page).to have_content(projet_56.demandeur.fullname)
      expect(page).to have_content(projet_34.adresse.ville)
      expect(page).to have_content(projet_34.adresse.code_postal)
      expect(page).to have_content(projet_56.agent_instructeur.intervenant.raison_sociale)
      expect(page).to have_content(projet_56.agent_instructeur.fullname)
      # #TODO Theme
      expect(page).to have_content(I18n.t("projets.statut.en_cours_d_instruction"))
      #TODO Update Status At
    end
  end

  context "pour un projet en cours d'instruction" do
    let(:projet)            { create :projet, :en_cours_d_instruction }
    let(:agent_operateur)   { projet.agent_operateur}
    let(:agent_instructeur) { projet.agent_instructeur}

    context "en tant qu'opérateur" do
      let(:current_agent) { agent_operateur }

      context "recommandé par un PRIS et engagé" do
        before { projet.invitations.where(intervenant_id: agent_operateur.intervenant.id).first.update(suggested: true) }

        scenario "j'ai accès au tableau de bord avec toutes les informations disponibles" do
          visit dossiers_path
          expect(page).to have_content(projet.numero_plateforme)
          expect(page).to have_content(projet.opal_numero)
          expect(page).to have_content(projet.demandeur.fullname)
          expect(page).to have_content(projet.adresse.ville)
          expect(page).to have_content(projet.adresse.code_postal)
          expect(page).to have_content(projet.agent_instructeur.intervenant.raison_sociale)
          expect(page).to have_content(projet.agent_instructeur.fullname)
          #TODO Theme
          expect(page).to have_content(projet.agent_operateur.intervenant.raison_sociale)
          expect(page).to have_content(projet.agent_operateur.fullname)
          expect(page).to have_content(I18n.t("projets.statut.en_cours_d_instruction"))
          #TODO Update Status At
        end

        scenario "je peux accéder à un dossier à partir du tableau de bord" do
          visit dossiers_path
          first(:link, projet.numero_plateforme).click
          expect(page.current_path).to eq(dossier_path(projet))
          expect(page).to have_content(projet.demandeur.fullname)
        end

        scenario "je ne peux pas accéder au dossier Opal" do
          visit dossiers_path
          expect(page).not_to have_link(projet.opal_numero, href: dossier_opal_url(projet.opal_numero))
        end
      end
    end
    context "en tant qu'instructeur" do
      let(:current_agent) { agent_instructeur }

      scenario "j'ai accès au tableau de bord avec toutes les informations disponibles" do
        visit dossiers_path
        expect(page).to     have_content(projet.numero_plateforme)
        expect(page).to     have_content(projet.opal_numero)
        expect(page).to     have_content(projet.demandeur.fullname)
        expect(page).not_to have_content(projet.adresse.region)
        expect(page).not_to have_css("td.test-departement")
        expect(page).to     have_content(projet.adresse.ville)
        expect(page).to     have_content(projet.agent_instructeur.intervenant.raison_sociale)
        expect(page).to     have_content(projet.agent_instructeur.fullname)
        #TODO Themes
        expect(page).to     have_content(I18n.t("projets.statut.en_cours_d_instruction"))
        #TODO Update Status At
      end

      scenario "je peux accéder à un dossier à partir du tableau de bord" do
        visit dossiers_path
        first(:link, projet.numero_plateforme).click
        expect(page.current_path).to eq(dossier_path(projet))
        expect(page).to have_content(projet.demandeur.fullname)
      end

      scenario "je peux accéder au dossier Opal" do
        visit dossiers_path
        expect(page).to have_link(projet.opal_numero, href: dossier_opal_url(projet.opal_numero))
      end
    end
  end

  context "pour un projet en prospect" do
    let(:projet)            { create :projet, :prospect, :with_invited_pris, :with_invited_instructeur }
    let(:operateur)         { create :operateur }
    let(:agent_pris)        { create :agent, :pris,        intervenant: projet.invited_pris }
    let(:agent_instructeur) { create :agent, :instructeur, intervenant: projet.invited_instructeur }

    context "en tant qu'opérateur" do
      let(:agent_operateur) { create :agent, :operateur, intervenant: operateur }
      let(:current_agent)   { agent_operateur }

      context "recommandé par un PRIS" do
        before { projet.suggest_operateurs!([operateur.id]) }

        scenario "j'ai accès au tableau de bord avec des données anonymisées" do
          visit dossiers_path
          expect(page).to have_no_link(projet.numero_plateforme)
        end
      end

      context "non recommandé par un PRIS" do
        scenario "je ne vois pas le projet" do
          visit dossiers_path
          expect(page).not_to have_css("#projet_#{projet.id}")
        end
      end
    end

    context "en tant que PRIS" do
      let(:current_agent) { agent_pris }

      scenario "j'ai accès au tableau de bord avec des données non anonymisées" do
        visit dossiers_path
        expect(page).to     have_content(projet.plateforme_id)
        expect(page).to     have_content(projet.demandeur.fullname)
        expect(page).not_to have_content(projet.adresse.region)
        expect(page).to     have_content(projet.adresse.ville)
        #TODO Themes
        expect(page).to     have_content(I18n.t("projets.statut.prospect"))
        #TODO Update Status At
      end

      scenario "je peux accéder à un dossier à partir du tableau de bord" do
        visit dossiers_path
        first(:link, projet.numero_plateforme).click
        expect(page.current_path).to eq(dossier_path(projet))
        expect(page).to have_content(projet.demandeur.fullname)
      end
    end
  end
end
