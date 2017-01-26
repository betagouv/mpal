require 'rails_helper'
require 'support/mpal_helper'
require 'support/api_particulier_helper'
require 'support/api_ban_helper'

feature 'messagerie' do
  let(:message) { "Vous ne m'avez toujours pas répondu." }
  let(:projet) {          create :projet }
  let(:operateur) {       create :intervenant, :operateur, departements: [projet.departement] }
  let(:agent_operateur) { create :agent, intervenant: operateur }

  context "en tant qu'intervenant" do
    before { login_as agent_operateur, scope: :agent }

    scenario "je veux ajouter un commentaire" do
      visit dossier_path(projet)
      fill_in :commentaire_corps_message, with: message
      click_button I18n.t('projets.visualisation.lien_ajout_commentaire')
      within ".chat-intervenant" do
        expect(page).to have_content(operateur.raison_sociale)
        expect(page).to have_content(message_operateur)
      end
    end
  end
end
