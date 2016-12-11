require 'rails_helper'
require 'support/mpal_helper'
require 'support/api_particulier_helper'
require 'support/api_ban_helper'

feature "transmettre à l'instructeur", pending: true do
  scenario "une demande valide" do
    projet = FactoryGirl.create(:projet)
    operateur = FactoryGirl.create(:intervenant, :operateur)
    invitation = FactoryGirl.create(:invitation, projet: projet, intervenant: operateur) 
    projet.statut = :en_cours
    projet.operateur = operateur
    projet.save

    Intervenant.instructeur.pour_departement(projet.departement).destroy_all
    instructeur = FactoryGirl.create(:intervenant, :instructeur, departements: [ projet.departement ])
    visit projet_demande_path(projet, jeton: invitation.token)

    click_button I18n.t('projets.demande.action', instructeur: instructeur.raison_sociale)
    expect(page).to have_content(I18n.t('projets.transmissions.messages.succes', intervenant: instructeur.raison_sociale))
    expect(projet.intervenants).to include(instructeur)

    visit projets_path(jeton: invitation.token)
    within "#projet_#{projet.id}" do
      expect(page).to have_content(I18n.t("projets.statut.transmis_pour_instruction"))
      expect(page).to have_content(projet.opal_numero)
    end
  end
end

