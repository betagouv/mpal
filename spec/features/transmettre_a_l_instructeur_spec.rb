require 'rails_helper'
require 'support/mpal_helper'
require 'support/api_particulier_helper'
require 'support/api_ban_helper'

feature "transmettre à l'instructeur" do

  before do
    Projet.destroy_all
    Demande.destroy_all
    Invitation.destroy_all
    Occupant.destroy_all
  end

  scenario "en tant que demandeur je transmet une demande aux services instructeurs" do
    projet = FactoryGirl.create(:projet)
    operateur = FactoryGirl.create(:intervenant, :operateur)
    invitation = FactoryGirl.create(:invitation, projet: projet, intervenant: operateur)
    projet.statut = :en_cours
    projet.operateur = invitation.intervenant
    projet.save
    # Intervenant.instructeur.pour_departement(projet.departement).destroy_all
    instructeur = FactoryGirl.create(:intervenant, :instructeur, departements: [ projet.departement ])
    signin(12, 15)
    expect(page.current_path).to eq(projet_path(projet))

    @role_utilisateur = :demandeur
    puts " -------- STATUT ------------- #{projet.statut}"
    puts " -------- ROLE ------------- #{@role_utilisateur}"
    puts " -------- OPERATEUR ------------- #{projet.operateur.raison_sociale}"
    # etape 3 l'opérateur fait une proposition

    expect(page).to have_content(I18n.t('projets.operateur_construit_proposition', operateur: projet.operateur.raison_sociale))

    projet.gain_energetique = 34
    projet.ventilation_adaptee = true
    projet.montant_travaux_ttc = 1500
    # étape 4 j'accepte la proposition

    projet.statut = :proposition_proposee
    # expect(page).to have_content('Engagements')
    expect(page).to have_content('Projet envisagé')
    expect(page).to have_content('Projet proposé')

    projet.statut = :proposition_proposee
    puts " -------- STATUT ------------- #{projet.statut}"
    # rend app/views/projets/_projet_proposition_proposee_demandeur.html.slim
    # qui rend projet_proposition
    # mais en fait ça appelle app/views/projets/_projet_en_cours_demandeur.html.slim
    visit projet_path(projet)
    # je peux signer les engagements et transmettre

    # expect(page).to have_content(I18n.t('projets.statut.bouton_accepter'))

    # expect(page).to have_content(I18n.t('projets.transmissions.messages.envoi_demande'))
    # click_button I18n.t('projets.transmissions.messages.envoi_demande')
    # expect(page).to have_content(I18n.t('projets.transmissions.messages.succes', intervenant: instructeur.raison_sociale))
    # expect(page).to have_content(I18n.t('projets.transmissions.messages.info_demandeur', instructeur: instructeur.raison_sociale))
    #
    # expect(projet.intervenants).to include(instructeur)


    # visit projets_path(jeton: invitation.token)
    # within "#projet_#{projet.id}" do
    #   expect(page).to have_content(I18n.t("projets.statut.transmis_pour_instruction"))
    #   expect(page).to have_content(projet.opal_numero)
    # end
  end
end
