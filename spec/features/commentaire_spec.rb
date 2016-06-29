require 'rails_helper'

feature 'commentaire' do
  let(:commentaire) { FactoryGirl.create(:commentaire) }
  let(:projet) { commentaire.projet }
  let(:message) { "Vous ne m'avez toujours pas répondu." }

  scenario "ajout d'un commentaire" do
    signin(projet.numero_fiscal, projet.reference_avis)
    visit projet_path(projet)

    fill_in :corps_message, with: message
    click_button I18n.t('projets.visualisation.lien_ajout_commentaire')
    expect(page).to have_content(message)
  end

end
