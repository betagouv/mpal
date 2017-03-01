require 'rails_helper'
require 'support/mpal_features_helper'
require 'support/api_particulier_helper'
require 'support/api_ban_helper'

feature "En tant que demandeur, je peux préciser mes besoins pour ma demande de travaux" do
  before do
    Projet.destroy_all
    Demande.destroy_all
    Invitation.destroy_all
    Occupant.destroy_all
  end

  let(:projet) { Projet.last }

  scenario "je décris précisément mes besoins" do
    signin(12,15)
    visit etape2_description_projet_path(projet)
    expect(page).to have_content(I18n.t('demarrage_projet.etape2_description_projet.section_projet_envisage'))
    # Liste des besoins
    check('demande_froid')
    check('demande_changement_chauffage')
    uncheck('demande_probleme_deplacement')
    check('demande_accessibilite')
    check('demande_hospitalisation')
    check('demande_adaptation_salle_de_bain')
    choose('demande_ptz_true')
    choose('demande_date_achevement_15_ans_true')
    fill_in :demande_complement, with: "J'ai besoin d'un jacuzzi"
    fill_in :demande_autre, with: "Mes fenêtres ferment mal"
    fill_in :demande_annee_construction, with: "1930"
    # Liste des travaux
    uncheck('demande_travaux_isolation')
    check('demande_travaux_fenetres')
    check('demande_travaux_chauffage')
    uncheck('demande_travaux_adaptation_sdb')
    check('demande_travaux_monte_escalier')
    check('demande_travaux_amenagement_ext')
    fill_in :demande_travaux_autres, with: "Aménager une chambre au RDC"

    click_button I18n.t('demarrage_projet.action')
    expect(page.current_path).to eq(etape3_mise_en_relation_path(projet))

    projet.reload
    expect(projet.demande.froid).to be_truthy
    expect(projet.demande.changement_chauffage).to be_truthy
    expect(projet.demande.date_achevement_15_ans).to be_truthy
    expect(projet.demande.probleme_deplacement).not_to be_truthy
    expect(projet.demande.complement).to eq("J'ai besoin d'un jacuzzi")
    expect(projet.demande.autre).to eq("Mes fenêtres ferment mal")
    expect(projet.demande.changement_chauffage).to be_truthy
    expect(projet.demande.adaptation_salle_de_bain).to be_truthy
    expect(projet.demande.accessibilite).to be_truthy
    expect(projet.demande.ptz).to be_truthy
    expect(projet.demande.annee_construction).to eq("1930")
    expect(projet.demande.travaux_isolation).not_to be_truthy
    expect(projet.demande.travaux_adaptation_sdb).not_to be_truthy
    expect(projet.demande.travaux_amenagement_ext).to be_truthy
    expect(projet.demande.travaux_monte_escalier).to be_truthy
    expect(projet.demande.travaux_chauffage).to be_truthy
    expect(projet.demande.travaux_fenetres).to be_truthy
    expect(projet.demande.travaux_autres).to eq("Aménager une chambre au RDC")
  end

  scenario "je ne décris aucun besoin à l'étape 2 et je ne peux pas passer à l'étape suivante" do
    signin(12,15)
    visit etape2_description_projet_path(projet)
    click_button I18n.t('demarrage_projet.action')
    expect(page.current_path).to eq(etape2_description_projet_path(projet))
    expect(page).to have_content(I18n.t("demarrage_projet.etape2_description_projet.erreurs.besoin_obligatoire"))
  end
end
