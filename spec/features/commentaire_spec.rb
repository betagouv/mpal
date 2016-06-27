require 'rails_helper'

feature 'commentaire' do
  let(:commentaire) { FactoryGirl.create(:commentaire)}

  scenario "ajout d'un commentaire" do
    # click_link I18n.t('projets.visualisation.commentaires.lien_ajout_commentaire')
  end
end
