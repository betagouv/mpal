require 'rails_helper'
require 'support/mpal_features_helper'
require 'support/api_ban_helper'

describe "En tant qu'opérateur ou demandeur, je peux modifier le projet :" do
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

  def resource_occupants_path(projet)
    send("#{resource_name}_occupants_path", projet)
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
      expect(find('#projet_occupant_civility_mr')).to be_checked
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

      # Add new avis imposition
      expect(page).to have_current_path resource_avis_impositions_path(projet)
      click_link 'Ajouter un avis d’imposition'
      expect(page).to have_current_path new_resource_avis_imposition_path(projet)
      fill_in 'avis_imposition_numero_fiscal',  with: Fakeweb::ApiParticulier::NUMERO_FISCAL_NON_ELIGIBLE
      fill_in 'avis_imposition_reference_avis', with: Fakeweb::ApiParticulier::REFERENCE_AVIS_NON_ELIGIBLE
      click_button 'Ajouter'

      expect(page).to have_current_path resource_avis_impositions_path(projet)
      expect(page).to have_content('1 000 000 €')

      # Delete avis imposition
      click_link 'Supprimer'
      expect(page).to have_current_path resource_avis_impositions_path(projet)
      expect(page).not_to have_content('1 000 000 €')
    end
  end

=begin
  shared_examples :can_edit_occupants do |resource_name|
    let(:resource_name) { resource_name }

    scenario "je peux modifier les occupants du foyer" do
      visit resource_path(projet)
      within 'article.occupants' do
        click_link I18n.t('projets.visualisation.lien_edition')
      end

      expect(page).to have_current_path resource_demandeur_path(projet)
      click_button I18n.t('demarrage_projet.action')

      expect(page).to have_current_path resource_avis_impositions_path(projet)
      click_link I18n.t('demarrage_projet.action')

      # Add new occupant
      visit dossier_occupants_path(projet)
      expect(page).to have_current_path dossier_occupants_path(projet)
      fill_in "Nom",               with: "Marielle"
      fill_in "Prénom",            with: "Jean-Pierre"
      fill_in "Date de naissance", with: "20/05/2010"
      click_button I18n.t("occupants.nouveau.action")

      expect(page).to have_current_path(dossier_occupants_path(projet))
      expect(page).to have_content("Jean-Pierre Marielle")

      # Delete occupant
      within "table tr:last-child" do
        click_link I18n.t('occupants.delete.action')
      end
      expect(page).to have_current_path(dossier_occupants_path(projet))
      expect(page).to have_content("Jean-Pierre Marielle")
    end
  end
=end

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
      expect(page).to have_content 1950
      # TODO: tester la modification des travaux demandés
    end
  end

  let(:user) { create :user }
  let(:projet) { create :projet, :prospect, :with_committed_operateur, user: user }

  context "en tant que demandeur" do
    before { login_as user, scope: :user }

    it_behaves_like :can_edit_demandeur,        "projet"
    it_behaves_like :can_edit_avis_impositions, "projet"
    it_behaves_like :can_edit_occupants,        "projet"
    it_behaves_like :can_edit_demande,          "projet"
  end

  context "en tant qu'opérateur" do
    let(:agent_operateur) { create :agent, intervenant: projet.operateur }
    before { login_as agent_operateur, scope: :agent }

    it_behaves_like :can_edit_demandeur,        "dossier"
    it_behaves_like :can_edit_avis_impositions, "dossier"
    it_behaves_like :can_edit_occupants,        "projet"
    it_behaves_like :can_edit_demande,          "dossier"
  end
end

describe "En tant qu'opérateur je peux modifier le RFR :" do
  let(:user) { create :user }
  let(:projet) { create :projet, :prospect, :with_committed_operateur, user: user }
  let(:agent_operateur) { create :agent, intervenant: projet.operateur }
  before { login_as agent_operateur, scope: :agent }

  context "si le modified RFR est vide ou nul" do
    it "affiche le RFR total " do
      expect(projet.reload.modified_revenu_fiscal_reference).to be_nil
      visit dossier_path(projet)
      expect(page).to have_content projet.reload.modified_revenu_fiscal_reference
      visit dossier_avis_impositions_path(projet)
      expect(page).to have_content "RFR Modifié"
      fill_in I18n.t("simple_form.labels.projet.modified_revenu_fiscal_reference"), with: 'Abc'
      click_button I18n.t('demarrage_projet.action')
      visit dossier_path(projet)
      expect(page).to have_content projet.reload.modified_revenu_fiscal_reference
    end
  end

  context "si le modified RFR est rempli" do
    it "affiche le modified RFR" do
      expect(projet.reload.modified_revenu_fiscal_reference).to be_nil
      visit dossier_avis_impositions_path(projet)
      fill_in I18n.t("simple_form.labels.projet.modified_revenu_fiscal_reference"), with: '123'
      click_button I18n.t('demarrage_projet.action')
      expect(page).to have_current_path dossier_occupants_path(projet)
      expect(projet.reload.modified_revenu_fiscal_reference).to eq 123
      expect(page).to have_content 123
      visit dossier_avis_impositions_path(projet)
      fill_in I18n.t("simple_form.labels.projet.modified_revenu_fiscal_reference"), with: '111'
      click_button I18n.t('demarrage_projet.action')
      expect(page).to have_current_path dossier_occupants_path(projet)
      expect(projet.reload.modified_revenu_fiscal_reference).to eq 111
    end

    it "met en avant la modification" do
    end
  end
end

describe "En tant que demandeur :" do
  let(:user) { create :user }
  let(:projet) { create :projet, user: user, modified_revenu_fiscal_reference: 111 }
  before { login_as user, scope: :user }

  context "Je ne peux pas modifier le RFR" do
    it "je ne peux jamais modifier le RFR" do
      visit projet_avis_impositions_path(projet)
      expect(page).to_not have_content "RFR Modifié"
    end

    it "affiche le modified RFR" do
      visit projet_path(projet)
      expect(page).to have_content("111")
    end
  end
end