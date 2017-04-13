require 'rails_helper'
require 'support/mpal_features_helper'
require 'support/api_ban_helper'

feature "Modifier le projet :" do
  shared_examples "je peux modifier les informations personnelles du demandeur" do
    specify do
      within 'article.occupants' do
        click_link I18n.t('projets.visualisation.lien_edition')
      end

      expect(page).to have_current_path projet_demandeur_path(projet)
      expect(find('#demandeur_principal_civilite_mr')).to be_checked
      expect(page).to have_field('Adresse postale', with: '65 rue de Rome, 75008 Paris')

      fill_in :projet_adresse_postale,   with: Fakeweb::ApiBan::ADDRESS_PORT
      fill_in :projet_adresse_a_renover, with: Fakeweb::ApiBan::ADDRESS_MARE
      fill_in :projet_tel, with: '01 10 20 30 40'

      click_button I18n.t('projets.edition.action')

      expect(page).to have_content('01 10 20 30 40')
      expect(page).to have_current_path projet_path(projet)
      expect(page).to have_content Fakeweb::ApiBan::ADDRESS_PORT
      expect(page).to have_content Fakeweb::ApiBan::ADDRESS_MARE
    end
  end

  shared_examples "je peux modifier les informations de l'habitation et de la demande" do
    specify do
      within 'article.projet' do
        click_link I18n.t('projets.visualisation.lien_edition')
      end
      fill_in :demande_annee_construction, with: '1950'
      click_button I18n.t('projets.edition.action')
      expect(page).to have_content(1950)
      # TODO: tester la modification des travaux demandés
    end
  end

  context "en tant que demandeur" do
    let(:projet) { create(:projet, :prospect, :with_invited_operateur) }
    before { signin(projet.numero_fiscal, projet.reference_avis) }

    it_behaves_like "je peux modifier les informations personnelles du demandeur"
    it_behaves_like "je peux modifier les informations de l'habitation et de la demande"
  end
end
