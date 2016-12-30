require 'rails_helper'
require 'support/mpal_helper'
require 'support/api_particulier_helper'
require 'support/api_ban_helper'

feature "Etape 1 de la création d'un projet, le demandeur visualise les infos récupérées par l'appel à api particulier et il les modifie et précise si besoin" do

  before do
    Projet.destroy_all
    Demande.destroy_all
    Invitation.destroy_all
    Occupant.destroy_all
  end

  scenario "Depuis la page de connexion, je recupère mes informations principales" do
    signin(12,15)
    projet = Projet.last
    expect(page.current_path).to eq(etape1_recuperation_infos_demarrage_projet_path(projet))
    expect(page).to have_content("Martin")
    expect(page).to have_content("Pierre")
    expect(projet.demandeur_principal_nom).to eq("Martin")
    expect(projet.demandeur_principal_prenom).to eq("Pierre")
    # attention j'ai fakeweb on dirait...
    expect(page).to have_content(I18n.t('demarrage_projet.etape1_demarrage_projet.section_demandeur'))
    expect(page).to have_content(I18n.t('demarrage_projet.etape1_demarrage_projet.section_occupants'))
    expect(find_field('projet_adresse').value).to eq('12 rue de la Mare, 75010 Paris')
    expect(page).to have_content(I18n.t('projets.messages.creation.corps'))
    expect(page).to have_content(I18n.t('projets.messages.creation.titre', demandeur_principal: projet.demandeur_principal))
  end

  scenario "je complète la civilité du demandeur principal" do
    signin(12,15)
    projet = Projet.last
    choose('occupant_civilite_mr')
    click_button I18n.t('demarrage_projet.action')
    expect(projet.demandeur_principal.civilite).to eq("mr")
  end

  scenario "mon e-mail doit être valide et obligatoire" do
    skip
    signin(12,15)
    projet = Projet.last
    fill_in :projet_email, with: ""
    fill_in 'projet_tel', with: "06 06 06 06 06"
    click_button I18n.t('demarrage_projet.action')
    expect(projet.tel).to eq("06 06 06 06 06")
    # expect message d'erreur
    # expect qu'on reste sur l'étape 1
  end

  scenario "Les noms et prénom du demandeur principal ne peuvent pas être modifiés" do
    skip
  end

  scenario "Je peux modifier l'adresse du logement à rénover si elle est différente de l'adresse fiscale" do
    skip
  end

  scenario "Je modifie l'adresse du logement à rénover" do
    skip
    # attention, pour le moment l'adresse récupérée est celle de l'avis d'imposition.
    # l'adresse du logement à rénover peut être différente, l'adresse postale également !
    # l'adresse est transmise à opal
    signin(12,15)
    projet = Projet.last
    expect(page.current_path).to eq(etape1_recuperation_infos_demarrage_projet_path(projet))
    fill_in :projet_adresse, with: "1 place Vendôme, 75001 Paris"
    fill_in :projet_email, with: "jean@jean.com"
    click_button I18n.t('demarrage_projet.action')
    expect(page.current_path).to eq(etape2_description_projet_path(projet))
    projet = Projet.last
    expect(projet.adresse_ligne1).to eq("12 rue de la Mare")
    expect(projet.code_postal).to eq("75010")
    expect(projet.ville).to eq("Paris")
  end

  scenario "j'ajoute une personne de confiance" do
    signin(12,15)
    projet = Projet.last
    within '.dem-diff.ins-form' do
      page.choose('Monsieur')
      fill_in 'projet_personne_de_confiance_attributes_prenom', with: "Frank"
      fill_in 'projet_personne_de_confiance_attributes_nom', with: "Strazzeri"
      fill_in 'projet_personne_de_confiance_attributes_tel', with: "0130201040"
      fill_in 'projet_personne_de_confiance_attributes_email', with: "frank@strazzeri.com"
      fill_in 'projet_personne_de_confiance_attributes_lien_avec_demandeur', with: "Mon jazzman favori et neanmoins concubin"
    end
    click_button I18n.t('demarrage_projet.action')
    expect(page.current_path).to eq(etape2_description_projet_path(projet))
    projet = Projet.last
    expect(projet.personne_de_confiance.civilite).to eq('Mr')
    expect(projet.personne_de_confiance.prenom).to eq("Frank")
    expect(projet.personne_de_confiance.nom).to eq("Strazzeri")
    expect(projet.personne_de_confiance.tel).to eq("0130201040")
    expect(projet.personne_de_confiance.email).to eq("frank@strazzeri.com")
    expect(projet.personne_de_confiance.lien_avec_demandeur).to eq("Mon jazzman favori et neanmoins concubin")
  end

  scenario "je peux supprimer un occupant" do
    skip
  end

  scenario "je vois la liste des personnes présentes dans l'avis d'imposition sous forme d'occupants" do
    signin(12,15)
    projet = Projet.last
    expect(projet.nb_total_occupants).to eq(3)
    expect(projet.occupants.count).to eq(1)
    expect(page).to have_content("Occupant 2")
    expect(page).to have_content("Occupant 3")
  end

  scenario "je vois les informations fiscales concernant le demandeur principal" do
    skip
  end

  scenario "je peux ajouter un occupant" do
    skip
  end
  scenario "si je ne coche pas la case d'engagements je ne peut pas accéder à la page suivante" do
    skip
    signin(12,15)
    projet = Projet.last
    expect(page).to have_content(I18n.t('agrements.attestation_communiquer_infos_occupants'))
  end

  scenario "j'ai commencé une demande, j'ai quitté la page puis j'ai recommancé la démarche depuis la page d'accueil" do
    skip
    # actuellement une erreur
    # https://github.com/sgmap/mpal/issues/198
  end

end
