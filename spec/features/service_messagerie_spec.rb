require 'rails_helper'
require 'support/mpal_features_helper'
require 'support/api_particulier_helper'
require 'support/api_ban_helper'

feature 'messagerie' do
  let(:user)              { create :user }
  let(:projet)            { create(:projet, :prospect, :with_contacted_operateur, :with_invited_instructeur, :with_invited_pris, user: user, locked_at: Time.new(2001, 2, 3, 4, 5, 6)) }
  let(:message_demandeur) { "Bonjour ! J'ai une question sur mon projet." }
  let(:message_operateur) { "J'attend votre question." }
  let(:operateur)         { create :operateur, departements: [projet.departement] }
  let(:agent_operateur)   { create :agent, intervenant: operateur }
  let!(:invitation)       { create :invitation, intervenant: operateur, projet: projet }

  context "en tant que demandeur dont l’éligibilité est figée" do
    before { login_as user, scope: :user }

    scenario "je veux ajouter un commentaire" do
      visit projet_path(projet)
      fill_in :commentaire_corps_message, with: message_demandeur
      click_button I18n.t('projets.visualisation.lien_ajout_commentaire')
      expect(page).to have_content(message_demandeur)
    end
  end

  context "en tant qu'intervenant" do
    before { login_as agent_operateur, scope: :agent }

    scenario "je veux répondre à un commentaire" do
      visit dossier_path(projet)
      fill_in :commentaire_corps_message, with: message_operateur
      click_button I18n.t('projets.visualisation.lien_ajout_commentaire')
      within ".chat-intervenant" do
        expect(page).to have_content(operateur.raison_sociale)
        expect(page).to have_content(message_operateur)
      end
    end
  end
end
