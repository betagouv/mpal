require 'rails_helper'
require 'support/mpal_helper'
require 'support/api_particulier_helper'
require 'support/api_ban_helper'

feature "Démarrer un projet" do
  before do
    Projet.destroy_all
    Demande.destroy_all
    Invitation.destroy_all
    Occupant.destroy_all
  end

  scenario "depuis la page d'accueil" do
    visit root_path
    click_on I18n.t('accueil.action')
    expect(page.current_path).to eq(new_session_path)
  end

  scenario "depuis la page de connexion, je recupere mes informations principales", pending: true do
    signin(12,15)
    projet = Projet.last
    expect(page.current_path).to eq(etape1_recuperation_infos_demarrage_projet_path(projet))
    expect(page).to have_content("Martin")
    expect(page).to have_content("Pierre")
    expect(page).to have_content("12 rue de la Mare")
    expect(page).to have_content("75010")
    expect(page).to have_content("Paris")
  end

  scenario "je modifie l'adresse du logement à rénover" do
    signin(12,15)
    projet = Projet.last
    expect(page.current_path).to eq(etape1_recuperation_infos_demarrage_projet_path(projet))
    fill_in :projet_adresse, with: "1 place Vendôme, 75001 Paris"
    fill_in 'projet_disponibilite', with: "Plutôt en journée pendant la semaine"

    click_button I18n.t('demarrage_projet.action')
    expect(page.current_path).to eq(etape2_description_projet_path(projet))
    projet = Projet.last
    expect(projet.adresse_ligne1).to eq("12 rue de la Mare")
    expect(projet.code_postal).to eq("75010")
    expect(projet.ville).to eq("Paris")
    expect(projet.disponibilite).to eq("Plutôt en journée pendant la semaine")
  end

  scenario "j'ajoute une personne de confiance" do
    signin(12,15)
    projet = Projet.last

    fill_in 'projet_personne_de_confiance_attributes_prenom', with: "Frank"
    fill_in 'projet_personne_de_confiance_attributes_nom', with: "Strazzeri"
    fill_in 'projet_personne_de_confiance_attributes_tel', with: "0130201040"
    fill_in 'projet_personne_de_confiance_attributes_email', with: "frank@strazzeri.com"
    fill_in 'projet_personne_de_confiance_attributes_lien_avec_demandeur', with: "Mon jazzman favori et neanmoins concubin"
    fill_in 'projet_tel', with: "06 06 06 06 06"
    click_button I18n.t('demarrage_projet.action')
    expect(page.current_path).to eq(etape2_description_projet_path(projet))

    projet = Projet.last
    expect(projet.tel).to eq("06 06 06 06 06")
    expect(projet.personne_de_confiance.prenom).to eq("Frank")
    expect(projet.personne_de_confiance.nom).to eq("Strazzeri")
    expect(projet.personne_de_confiance.tel).to eq("0130201040")
    expect(projet.personne_de_confiance.email).to eq("frank@strazzeri.com")
    expect(projet.personne_de_confiance.lien_avec_demandeur).to eq("Mon jazzman favori et neanmoins concubin")
  end

  scenario "je décris précisément mes besoins" do
    signin(12,15)
    projet = Projet.last
    visit etape2_description_projet_path(projet)
    check('demande_froid')
    check('demande_probleme_deplacement')
    check('demande_handicap')
    check('demande_mauvais_etat')
    fill_in :demande_autres_besoins, with: "J'ai besoin d'un jacuzzi"
    check('demande_changement_chauffage')
    uncheck('demande_isolation')
    check('demande_adaptation_salle_de_bain')
    check('demande_accessibilite')
    check('demande_travaux_importants')
    click_button I18n.t('demarrage_projet.action')
    expect(page.current_path).to eq(etape3_infos_complementaires_path(projet))

    projet = Projet.last
    expect(projet.demande.froid).to be_truthy
    expect(projet.demande.probleme_deplacement).to be_truthy
    expect(projet.demande.handicap).to be_truthy
    expect(projet.demande.mauvais_etat).to be_truthy
    expect(projet.demande.autres_besoins).to eq("J'ai besoin d'un jacuzzi")
    expect(projet.demande.changement_chauffage).to be_truthy
    expect(projet.demande.isolation).not_to be_truthy
    expect(projet.demande.adaptation_salle_de_bain).to be_truthy
    expect(projet.demande.accessibilite).to be_truthy
    expect(projet.demande.travaux_importants).to be_truthy
  end

  scenario "je ne décris aucun besoin" do
    signin(12,15)
    projet = Projet.last
    visit etape2_description_projet_path(projet)
    click_button I18n.t('demarrage_projet.action')
    expect(page.current_path).to eq(etape2_description_projet_path(projet))
    expect(page).to have_content(I18n.t("demarrage_projet.etape2_description_projet.erreurs.besoin_obligatoire"))
  end

  scenario "j'ajoute des infos complémentaires" do
    signin(12,15)
    projet = Projet.last
    visit etape3_infos_complementaires_path(projet)
    check('demande_ptz')
    check('demande_devis')
    check('demande_travaux_engages')
    fill_in :demande_annee_construction, with: "1930"
    check('demande_maison_individuelle')
    click_button I18n.t('demarrage_projet.action')
    expect(page.current_path).to eq(etape4_choix_operateur_path(projet))

    projet = Projet.last
    expect(projet.demande.ptz).to be_truthy
    expect(projet.demande.devis).to be_truthy
    expect(projet.demande.travaux_engages).to be_truthy
    expect(projet.demande.annee_construction).to eq("1930")
    expect(projet.demande.maison_individuelle).to be_truthy
  end

  scenario "J'invite le pris ou un opérateur à consulter mon projet" do
    signin(12,15)
    projet = Projet.last
    projet.demande = FactoryGirl.create(:demande)
    operateur = FactoryGirl.create(:intervenant, departements: [projet.departement], roles: [:operateur])
    visit etape4_choix_operateur_path(projet)
    within "#intervenant_#{operateur.id}" do
      click_link I18n.t('projets.visualisation.invitation_intervenant')
    end
    expect(page.current_path).to eq(projet_path(projet))
    expect(page).to have_content(I18n.t('invitations.messages.succes', intervenant: operateur.raison_sociale))
  end
end
