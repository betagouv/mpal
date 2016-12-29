require 'rails_helper'
require 'support/mpal_helper'
require 'support/api_particulier_helper'
require 'support/api_ban_helper'

feature 'messagerie' do
  # let(:commentaire) { FactoryGirl.create(:commentaire) }
  # let(:projet) { commentaire.projet }
  let(:message) { "Vous ne m'avez toujours pas répondu." }
  let(:invitation) { FactoryGirl.create(:invitation) }
  # let(:projet) { invitation.projet }

  scenario "ajout d'un commentaire par un intervenant" do
    visit projet_path(id: invitation.projet, jeton: invitation.token)
    fill_in :commentaire_corps_message, with: message
    click_button I18n.t('projets.visualisation.lien_ajout_commentaire')
    expect(page).to have_content(message)
  end

end
