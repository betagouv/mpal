require 'rails_helper'
require 'support/mpal_features_helper'
require 'support/api_ban_helper'

feature "Modifier le projet :" do
  def resource_path(projet)
    send("#{resource_name}_path", projet)
  end

  def resource_demandeur_path(projet)
    send("#{resource_name}_demandeur_path", projet)
  end

  def resource_avis_impositions_path(projet)
    send("#{resource_name}_avis_impositions_path", projet)
  end

  def new_resource_avis_imposition_path(projet)
    send("new_#{resource_name}_avis_imposition_path", projet)
  end

  def resource_demande_path(projet)
    send("#{resource_name}_demande_path", projet)
  end

  shared_examples :can_edit_demandeur do |resource_name|
    let(:resource_name) { resource_name }

    scenario "je peux modifier les informations personnelles du demandeur" do
      visit resource_path(projet)
      within 'article.occupants' do
        click_link I18n.t('projets.visualisation.lien_edition')
      end

      expect(page).to have_current_path resource_demandeur_path(projet)
      expect(find('#demandeur_principal_civilite_mr')).to be_checked
      expect(page).to have_field('Adresse postale', with: '65 rue de Rome, 75008 Paris')

      fill_in :projet_adresse_postale,   with: Fakeweb::ApiBan::ADDRESS_PORT
      fill_in :projet_adresse_a_renover, with: Fakeweb::ApiBan::ADDRESS_MARE
      fill_in :projet_tel, with: '01 10 20 30 40'

      click_button I18n.t('demarrage_projet.action')
      expect(page).to have_current_path resource_avis_impositions_path(projet)

      visit resource_path(projet)
      expect(page).to have_content('01 10 20 30 40')
      expect(page).to have_current_path resource_path(projet)
      expect(page).to have_content Fakeweb::ApiBan::ADDRESS_PORT
      expect(page).to have_content Fakeweb::ApiBan::ADDRESS_MARE
    end
  end

  shared_examples :can_edit_avis_impositions do |resource_name|
    let(:resource_name) { resource_name }

    scenario "je peux modifier les avis d'impositions du foyer" do
      visit resource_path(projet)
      within 'article.occupants' do
        click_link I18n.t('projets.visualisation.lien_edition')
      end

      expect(page).to have_current_path resource_demandeur_path(projet)
      click_button I18n.t('demarrage_projet.action')

      expect(page).to have_current_path resource_avis_impositions_path(projet)
      click_link 'Ajouter un avis d’imposition'
      expect(page).to have_current_path new_resource_avis_imposition_path(projet)
      fill_in 'avis_imposition_numero_fiscal',  with: 13
      fill_in 'avis_imposition_reference_avis', with: 16
      click_button 'Ajouter'

      expect(page).to have_current_path resource_avis_impositions_path(projet)
      expect(page).to have_content('1 000 000 €')

      click_link 'Supprimer'
      expect(page).to have_current_path resource_avis_impositions_path(projet)
      expect(page).not_to have_content('1 000 000 €')
    end
  end

  shared_examples :can_edit_demande do |resource_name|
    let(:resource_name) { resource_name }

    scenario "je peux modifier les informations de l'habitation et de la demande" do
      visit resource_path(projet)
      within 'article.projet' do
        click_link I18n.t('projets.visualisation.lien_edition')
      end

      expect(page).to have_current_path resource_demande_path(projet)
      fill_in :demande_annee_construction, with: '1950'
      click_button I18n.t('projets.edition.action')

      expect(page).to have_current_path resource_path(projet)
      expect(page).to have_content(1950)
      # TODO: tester la modification des travaux demandés
    end
  end

  let(:projet) { create(:projet, :prospect, :with_committed_operateur) }

  context "en tant que demandeur" do
    before { signin(projet.numero_fiscal, projet.reference_avis) }

    it_behaves_like :can_edit_demandeur, "projet"
    it_behaves_like :can_edit_avis_impositions, "projet"
    it_behaves_like :can_edit_demande, "projet"
  end

  context "en tant qu'opérateur" do
    let(:agent_operateur) { create :agent, intervenant: projet.operateur }
    before { login_as agent_operateur, scope: :agent }

    it_behaves_like :can_edit_demandeur, "dossier"
    it_behaves_like :can_edit_avis_impositions, "dossier"
    it_behaves_like :can_edit_demande, "dossier"
  end
end
