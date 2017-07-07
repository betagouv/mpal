require 'rails_helper'
require 'support/mpal_features_helper'
require 'support/api_ban_helper'
require 'support/rod_helper'

describe "En tant qu'opérateur" do
  let(:projet) { create :projet, :prospect, :with_committed_operateur }
  let(:agent_operateur) { create :agent, intervenant: projet.operateur }

  before { login_as agent_operateur, scope: :agent }

  scenario "je peux modifier les informations personnelles du demandeur" do
    visit dossier_path(projet)
    within 'article.occupants' do
      click_link I18n.t('projets.visualisation.lien_edition')
    end

    expect(page).to have_current_path dossier_demandeur_path(projet)
    expect(find('#projet_occupant_civility_mr')).to be_checked
    expect(page).to have_field('Adresse postale', with: '65 rue de Rome, 75008 Paris')

    fill_in :projet_adresse_postale,   with: Fakeweb::ApiBan::ADDRESS_PORT
    fill_in :projet_adresse_a_renover, with: Fakeweb::ApiBan::ADDRESS_MARE
    fill_in :projet_tel, with: '01 10 20 30 40'

    click_button I18n.t('demarrage_projet.action')
    expect(page).to have_current_path dossier_avis_impositions_path(projet)

    visit dossier_path(projet)
    expect(page).to have_content('01 10 20 30 40')
    expect(page).to have_current_path dossier_path(projet)
    expect(page).to have_content Fakeweb::ApiBan::ADDRESS_PORT
    expect(page).to have_content Fakeweb::ApiBan::ADDRESS_MARE
  end

  scenario "je peux modifier les avis d'impositions du foyer" do
    visit dossier_path(projet)
    within 'article.occupants' do
      click_link I18n.t('projets.visualisation.lien_edition')
    end

    expect(page).to have_current_path dossier_demandeur_path(projet)
    click_button I18n.t('demarrage_projet.action')

    # Add new avis imposition
    expect(page).to have_current_path dossier_avis_impositions_path(projet)
    click_link 'Ajouter un avis d’imposition'
    expect(page).to have_current_path new_dossier_avis_imposition_path(projet)
    fill_in 'avis_imposition_numero_fiscal',  with: Fakeweb::ApiParticulier::NUMERO_FISCAL_NON_ELIGIBLE
    fill_in 'avis_imposition_reference_avis', with: Fakeweb::ApiParticulier::REFERENCE_AVIS_NON_ELIGIBLE
    click_button 'Ajouter'

    expect(page).to have_current_path dossier_avis_impositions_path(projet)
    expect(page).to have_content('1 000 000 €')

    # Delete avis imposition
    click_link 'Supprimer'
    expect(page).to have_current_path dossier_avis_impositions_path(projet)
    expect(page).not_to have_content('1 000 000 €')
  end

  scenario "je peux modifier les occupants du foyer" do
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

  scenario "je peux modifier les informations de l'habitation et de la demande" do
    visit dossier_path(projet)
    within 'article.projet' do
      click_link I18n.t('projets.visualisation.lien_edition')
    end

    expect(page).to have_current_path dossier_demande_path(projet)
    fill_in :demande_annee_construction, with: '1950'
    click_button I18n.t('projets.edition.action')

    expect(page).to have_current_path dossier_path(projet)
    expect(page).to have_content 1950
    # TODO: tester la modification des travaux demandés
  end

  describe "je peux modifier le RFR :" do
    context "si le modified RFR est vide" do
      it "affiche le RFR total initial" do
        visit dossier_avis_impositions_path(projet)
        expect(page).to have_content I18n.t("simple_form.labels.projet.modified_revenu_fiscal_reference")
        fill_in I18n.t("simple_form.labels.projet.modified_revenu_fiscal_reference"), with: 'Abc'
        click_button I18n.t('demarrage_projet.action')
        visit dossier_path(projet)
        expect(page).to have_content "29 880 €"
        expect(page).to_not have_content "initialement"
      end
    end

    context "si le modified RFR est rempli" do
      it "affiche le modified RFR" do
        visit dossier_avis_impositions_path(projet)
        fill_in I18n.t("simple_form.labels.projet.modified_revenu_fiscal_reference"), with: '123'
        click_button I18n.t('demarrage_projet.action')
        expect(page).to have_current_path dossier_occupants_path(projet)
        expect(page).to have_content 123
        visit dossier_avis_impositions_path(projet)
        fill_in I18n.t("simple_form.labels.projet.modified_revenu_fiscal_reference"), with: '111'
        click_button I18n.t('demarrage_projet.action')
        expect(page).to have_current_path dossier_occupants_path(projet)
      end

      it "met en avant la modification" do
        visit dossier_avis_impositions_path(projet)
        fill_in I18n.t("simple_form.labels.projet.modified_revenu_fiscal_reference"), with: '123'
        click_button I18n.t('demarrage_projet.action')
        visit dossier_path(projet)
        expect(page).to have_content 123
        expect(page).to have_content "123 €"
        expect(page).to have_content "(initialement 29 880 €)"
      end
    end
  end
end

describe "En tant que demandeur :" do
  let(:user) { create :user }
  let(:projet) { create :projet, :with_avis_imposition, :with_invited_pris,  user: user, modified_revenu_fiscal_reference: 111, locked_at: Time.new(2001, 2, 3, 4, 5, 6) }

  before { login_as user, scope: :user }

  context "une fois l'éligibilité vérouillée" do
    it "Je ne peux pas accéder aux pages pour modifier mon projet" do
      visit projet_demandeur_path(projet)
      expect(page).to have_current_path projet_path(projet)

      visit projet_avis_impositions_path(projet)
      expect(page).to have_current_path projet_path(projet)

      visit projet_occupants_path(projet)
      expect(page).to have_current_path projet_path(projet)

      visit projet_demande_path(projet)
      expect(page).to have_current_path projet_path(projet)

    end

    it "affiche le modified RFR" do
      visit projet_path(projet)
      expect(page).to have_content("111 €")
      expect(page).to have_content("initialement 29 880 €")
    end
  end
end
