require 'rails_helper'
require 'support/mpal_features_helper'
require 'support/api_particulier_helper'
require 'support/api_ban_helper'
require 'support/rod_helper'

feature "Remplir la proposition de travaux" do
  let(:projet)            { create :projet, :hma_projet }
  let(:operateur)         { projet.operateur }
  let(:agent_operateur)   { create :agent, intervenant: operateur }
  let!(:theme_1)          { create :theme }
  let!(:theme_2)          { create :theme }
  let!(:prestation_1)     { create :prestation }
  let!(:prestation_2)     { create :prestation }
  let!(:prestation_3)     { create :prestation }
  let!(:aide_1)           { create :aide }
  let!(:aide_2)           { create :aide }

  context "en tant qu'opérateur" do
    before do
      Fakeweb::Rod.list_department_intervenants_helper
      login_as agent_operateur, scope: :agent
    end

    scenario "je visualise la proposition de travaux pour m'affecter le projet" do
      expect(projet.demande.eligible_hma).to eq true
      expect(ENV['ELIGIBLE_HMA']).to eq 'true'
      visit dossier_path(projet)
      click_link I18n.t('projets.visualisation.remplir_le_projet')
      expect(page).to have_current_path(dossier_proposition_path(projet))

      expect(page).to have_field('projet_numero_siret')
      expect(page).to have_content I18n.t('projets.visualisation.projet_affecte')
    end

    scenario "je remplis et j'enregistre une proposition de travaux'" do
      visit dossier_proposition_path(projet)
      expect(projet.demande.eligible_hma).to eq true
      expect(ENV['ELIGIBLE_HMA']).to eq 'true'
      expect(page).to have_content('Projet proposé par l’opérateur')

      # Section "Logement"
      fill_in 'projet_numero_siret', with: '73282932000074'

      # Section "Montant"
      # fill_in_section_montant

      # Section "Financement"
      fill_in aide_1.libelle, with: '6 666,66'
      fill_in aide_2.libelle, with: '7 777,77'

      # Section "Financement personnel"
      fill_in I18n.t('helpers.label.proposition.personal_funding_amount'), with: '8 888,88'
      fill_in I18n.t('helpers.label.proposition.loan_amount'), with: '9 999,99'

      # Section "Précisions"
      fill_in I18n.t('helpers.label.proposition.precisions_travaux'), with: 'Il faudra casser un mur.'
      fill_in I18n.t('helpers.label.proposition.precisions_financement'), with: 'Le prêt sera sans doute accordé.'

      click_on 'Enregistrer cette proposition'
      expect(page.current_path).to eq(dossier_path(projet))

    end
  end
end

