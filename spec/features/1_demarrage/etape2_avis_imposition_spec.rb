require 'rails_helper'
require 'support/mpal_features_helper'

feature "Avis d'imposition :" do
  let(:projet) { create(:projet, :with_demandeur) }

  context "en tant que demandeur avec l'avis d'imposition initial" do
    scenario "je peux ajouter un autre avis d'imposition" do
      signin(projet.numero_fiscal, projet.reference_avis)
      visit projet_avis_impositions_path(projet)

      expect(page).to have_content('29 880 €')
      click_link 'Ajouter un avis d’imposition'

      expect(page.current_path).to eq(new_projet_avis_imposition_path(projet))
      fill_in 'avis_imposition_numero_fiscal',  with: Fakeweb::ApiParticulier::NUMERO_FISCAL_NON_ELIGIBLE
      fill_in 'avis_imposition_reference_avis', with: Fakeweb::ApiParticulier::REFERENCE_AVIS_NON_ELIGIBLE
      click_button 'Ajouter'

      expect(page.current_path).to eq(projet_avis_impositions_path(projet))
      expect(page).to have_content('1 000 000 €')
    end

    scenario "je suis notifié que je ne peux pas ajouter un avis d'imposition invalide" do
      signin(projet.numero_fiscal, projet.reference_avis)
      visit projet_avis_impositions_path(projet)

      click_link 'Ajouter un avis d’imposition'

      expect(page.current_path).to eq(new_projet_avis_imposition_path(projet))
      fill_in 'avis_imposition_numero_fiscal',  with: Fakeweb::ApiParticulier::INVALID
      fill_in 'avis_imposition_reference_avis', with: Fakeweb::ApiParticulier::INVALID
      click_button 'Ajouter'

      expect(page.current_path).to eq(new_projet_avis_imposition_path(projet))
      expect(page).to have_content(I18n.t("sessions.invalid_credentials"))
    end
  end

  context "en tant que demandeur avec un avis d'imposition supplémentaire" do
    let(:numero_fiscal)     { Fakeweb::ApiParticulier::NUMERO_FISCAL_NON_ELIGIBLE }
    let(:reference_avis)    { Fakeweb::ApiParticulier::REFERENCE_AVIS_NON_ELIGIBLE }
    let(:avis_imposition_2) { create :avis_imposition, numero_fiscal: numero_fiscal, reference_avis: reference_avis }
    before { projet.avis_impositions << avis_imposition_2 }

    scenario "je peux supprimer cet avis d'imposition" do
      signin(projet.numero_fiscal, projet.reference_avis)
      visit projet_avis_impositions_path(projet)

      expect(page).to have_content('29 880 €')
      expect(page).to have_content('1 000 000 €')
      click_link 'Supprimer'

      expect(page).to have_content('29 880 €')
      expect(page).not_to have_content('1 000 000 €')
    end
  end
end
