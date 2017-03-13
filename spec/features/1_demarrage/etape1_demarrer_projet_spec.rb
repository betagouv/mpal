require 'rails_helper'
require 'support/mpal_features_helper'
require 'support/api_particulier_helper'
require 'support/api_ban_helper'

feature "En tant que demandeur, je peux vérifier et corriger mes informations personnelles" do
  let(:projet) { Projet.last }

  scenario "Depuis la page de connexion, je recupère mes informations principales" do
    signin_for_new_projet
    expect(page.current_path).to eq(etape1_recuperation_infos_path(projet))
    expect(page).to have_content("Martin")
    expect(page).to have_content("Pierre")
    expect(projet.demandeur_principal_nom).to eq("Martin")
    expect(projet.demandeur_principal_prenom).to eq("Pierre")
    expect(page).to have_content(I18n.t('demarrage_projet.etape1_demarrage_projet.section_demandeur'))
    expect(page).to have_content(I18n.t('demarrage_projet.etape1_demarrage_projet.section_occupants'))
    expect(find_field('projet_adresse_postale').value).to eq('12 rue de la Mare, 75010 Paris')
    expect(page).to have_content(I18n.t('projets.messages.creation.corps'))
    expect(page).to have_content(I18n.t('projets.messages.creation.titre', demandeur_principal: projet.demandeur_principal.fullname))
  end

  scenario "je complète la civilité du demandeur principal" do
    signin_for_new_projet
    within '.civilite' do
      choose('Monsieur')
    end
    fill_in :projet_email, with: "demandeur@exemple.fr"
    click_button I18n.t('demarrage_projet.action')
    expect(projet.demandeur_principal.civilite).to eq("mr")
  end

  context "quand je rentre des données invalides" do
    scenario "je vois un message d'erreur" do
      signin_for_new_projet
      fill_in :projet_email, with: "invalid-email@lol"
      fill_in 'projet_tel', with: "06 06 06 06 06"
      click_button I18n.t('demarrage_projet.action')
      expect(page).to have_current_path etape1_recuperation_infos_path(projet)
      expect(page).to have_content("L’adresse email n’est pas valide")
      expect(page).to have_field('Email', with: 'invalid-email@lol')
      expect(page).to have_field('Téléphone', with: '06 06 06 06 06')
    end
  end

  scenario "je dois rentrer une adresse" do
    signin_for_new_projet
    fill_in :projet_adresse_postale, with: nil
    click_button I18n.t('demarrage_projet.action')
    expect(page).to have_current_path(etape1_recuperation_infos_path(projet))
    expect(page).to have_content(I18n.t('demarrage_projet.etape1_demarrage_projet.erreurs.adresse_vide'))
  end

  scenario "je peux ajouter l'adresse du logement à rénover" do
    signin_for_new_projet
    fill_in :projet_email, with: "demandeur@exemple.fr"
    fill_in :projet_adresse_a_renover, with: Fakeweb::ApiBan::ADDRESS_PORT
    click_button I18n.t('demarrage_projet.action')

    projet.reload
    expect(page).to have_current_path etape2_description_projet_path(projet)
    expect(projet.adresse_a_renover.ligne_1).to eq("8 Boulevard du Port")
    expect(projet.adresse_a_renover.code_postal).to eq("80000")
    expect(projet.adresse_a_renover.ville).to eq("Amiens")
  end

  scenario "j'ajoute une personne de confiance" do
    signin_for_new_projet
    fill_in :projet_email, with: "demandeur@exemple.fr"
    page.choose I18n.t('demarrage_projet.etape1_demarrage_projet.personne_confiance_choix2')
    within '.dem-diff.ins-form' do
      page.choose('Monsieur')
      fill_in 'projet_personne_attributes_prenom', with: "Frank"
      fill_in 'projet_personne_attributes_nom', with: "Strazzeri"
      fill_in 'projet_personne_attributes_tel', with: "0130201040"
      fill_in 'projet_personne_attributes_email', with: "frank@strazzeri.com"
      fill_in 'projet_personne_attributes_lien_avec_demandeur', with: "Mon jazzman favori et neanmoins concubin"
    end
    click_button I18n.t('demarrage_projet.action')
    expect(page.current_path).to eq(etape2_description_projet_path(projet))
    projet.reload
    expect(projet.personne.civilite).to eq('Mr')
    expect(projet.personne.prenom).to eq("Frank")
    expect(projet.personne.nom).to eq("Strazzeri")
    expect(projet.personne.tel).to eq("0130201040")
    expect(projet.personne.email).to eq("frank@strazzeri.com")
    expect(projet.personne.lien_avec_demandeur).to eq("Mon jazzman favori et neanmoins concubin")
  end

  scenario "je vois la liste des personnes présentes dans l'avis d'imposition sous forme d'occupants" do
    signin_for_new_projet
    expect(projet.nb_total_occupants).to eq(3)
    expect(projet.occupants.count).to eq(1)
    expect(page).to have_content("Occupant 2")
    expect(page).to have_content("Occupant 3")
  end
end
