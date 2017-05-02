require 'rails_helper'
require 'support/mpal_features_helper'
require 'support/api_particulier_helper'
require 'support/api_ban_helper'

feature "En tant que demandeur, je peux vérifier et corriger mes informations personnelles" do
  let(:projet) { Projet.last }

  scenario "Depuis la page de connexion, je récupère mes informations principales" do
    signin_for_new_projet
    expect(page.current_path).to eq(projet_demandeur_path(projet))
    expect(page).to have_content(I18n.t('projets.messages.creation.titre'))
    expect(page).to have_content(I18n.t('projets.messages.creation.corps'))
    expect(page).to have_content(I18n.t('demarrage_projet.demandeur.section_demandeur'))
    expect(page).to have_select(I18n.t('demarrage_projet.demandeur.demandeur_identity'))
    expect(find_field('projet_adresse_postale').value).to eq('12 rue de la Mare, 75010 Paris')
  end

  scenario "je remplis mes informations personnelles" do
    signin_for_new_projet
    within '.civilite' do choose "Monsieur" end
    select "Pierre Martin"
    fill_in :projet_email, with: "demandeur@exemple.fr"
    fill_in :projet_tel,   with: "01 02 03 04 05"
    click_button I18n.t('demarrage_projet.action')

    expect(page).to have_current_path projet_avis_impositions_path(projet)
    expect(projet.demandeur_principal.civilite).to eq("mr")
    expect(projet.email).to eq("demandeur@exemple.fr")
    expect(projet.tel).to eq("01 02 03 04 05")
  end

  context "quand je rentre des données invalides" do
    scenario "je vois un message d'erreur" do
      signin_for_new_projet
      fill_in :projet_email, with: "invalid-email@lol"
      fill_in 'projet_tel', with: "999"
      click_button I18n.t('demarrage_projet.action')

      expect(page).to have_current_path projet_demandeur_path(projet)
      expect(page).to have_content("L’adresse email n’est pas valide")
      expect(page).to have_field("Email", with: "invalid-email@lol")
      expect(page).to have_content("Le numéro de téléphone est trop court")
      expect(page).to have_field("Téléphone", with: "999")
    end
  end

  scenario "je dois rentrer une adresse" do
    signin_for_new_projet
    fill_in :projet_adresse_postale, with: nil
    click_button I18n.t('demarrage_projet.action')
    expect(page).to have_current_path(projet_demandeur_path(projet))
    expect(page).to have_content(I18n.t('demarrage_projet.demandeur.erreurs.adresse_vide'))
  end

  scenario "je peux ajouter l'adresse du logement à rénover" do
    signin_for_new_projet
    within '.civilite' do choose('Monsieur') end
    select "Pierre Martin"
    fill_in :projet_email, with: "demandeur@exemple.fr"
    fill_in :projet_adresse_a_renover, with: Fakeweb::ApiBan::ADDRESS_PORT
    click_button I18n.t('demarrage_projet.action')

    projet.reload
    expect(page).to have_current_path projet_avis_impositions_path(projet)
    expect(projet.adresse_a_renover.ligne_1).to eq("8 Boulevard du Port")
    expect(projet.adresse_a_renover.code_postal).to eq("80000")
    expect(projet.adresse_a_renover.ville).to eq("Amiens")
  end

  scenario "j'ajoute une personne de confiance" do
    signin_for_new_projet
    within '.civilite' do choose('Monsieur') end
    select "Pierre Martin"
    fill_in :projet_email, with: "demandeur@exemple.fr"
    page.choose I18n.t('demarrage_projet.demandeur.personne_confiance_choix2')
    within '.dem-diff.ins-form' do
      page.choose('Monsieur')
      fill_in 'projet_personne_attributes_prenom', with: "Frank"
      fill_in 'projet_personne_attributes_nom', with: "Strazzeri"
      fill_in 'projet_personne_attributes_tel', with: "0130201040"
      fill_in 'projet_personne_attributes_email', with: "frank@strazzeri.com"
      fill_in 'projet_personne_attributes_lien_avec_demandeur', with: "Mon jazzman favori et neanmoins concubin"
    end
    click_button I18n.t('demarrage_projet.action')
    expect(page.current_path).to eq(projet_avis_impositions_path(projet))
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
    visit projet_occupants_path(projet)
    expect(projet.nb_total_occupants).to eq(4)
    expect(projet.occupants.count).to eq(4)
    expect(page).to have_content("Occupant 3")
    expect(page).to have_content("Occupant 4")
  end
end
