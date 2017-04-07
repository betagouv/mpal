require 'rails_helper'
require 'support/mpal_features_helper'
require 'support/api_particulier_helper'
require 'support/api_ban_helper'

feature "Transmettre à l'instructeur :" do
  let(:projet) { create :projet, :proposition_proposee, :with_intervenants_disponibles }

  context "en tant que demandeur" do
    scenario "je transmets mon projet aux services instructeurs" do
      signin(projet.numero_fiscal, projet.reference_avis)
      expect(page).to have_current_path(projet_path(projet))
      click_link I18n.t('projets.transmission.bouton_accepter')

      expect(page).to have_current_path(projet_transmission_path(projet))
      expect(find_field('projet_email').value).to eq 'prenom.nom@site.com'
      fill_in 'projet_email', with: 'lala@toto.com'
      check 'confirm'
      click_button I18n.t('projets.transmission.envoi_demande')

      instructeur = Intervenant.instructeur_pour(projet)
      expect(page).to have_current_path(projet_path(projet))
      expect(page).to have_content(I18n.t('projets.transmission.messages.success', instructeur: instructeur.raison_sociale))
      expect(page).to have_content(I18n.t('projets.statut.transmis_pour_instruction').downcase)
    end

    scenario "je suis notifié si mon email n'est pas valide" do
      signin(projet.numero_fiscal, projet.reference_avis)
      expect(page).to have_current_path(projet_path(projet))
      click_link I18n.t('projets.transmission.bouton_accepter')

      fill_in 'projet_email', with: 'lalatoto.com'
      check 'confirm'
      click_button I18n.t('projets.transmission.envoi_demande')

      expect(page).to have_current_path(projet_transmission_path(projet))
      expect(page).to have_content(I18n.t('projets.transmission.messages.validation_email'))
    end
  end
end
