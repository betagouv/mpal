require 'rails_helper'
require 'support/mpal_helper'

feature "En tant que demandeur, j'ai accès aux données concernant mon projet" do
  let(:projet) { create(:projet, :with_invited_operateur) }

  scenario "je peux consulter mon projet en me connectant" do
    signin(projet.numero_fiscal, projet.reference_avis)
    @role_utilisateur = :demandeur
    expect(page).to have_content("Jean Martin")
    expect(page).to have_content("Total Revenu Fiscal de Référence")
  end

  scenario "je peux modifier mes données personnelles et celles des occupants du logement" do
    signin(projet.numero_fiscal, projet.reference_avis)
    within 'article.occupants' do
      click_link I18n.t('projets.visualisation.lien_edition')
    end
    expect(find('#demandeur_principal_civilite_mr')).to be_checked
    fill_in :projet_tel, with: '01 10 20 30 40'
    click_button I18n.t('projets.edition.action')
    expect(page).to have_content('01 10 20 30 40')
    # TODO: tester les autres données personnelles
    # TODO: tester la mise à jour des occupants
  end

  scenario "je ne peux pas modifier mon adresse", pending: true do
    # FIXME: l'adresse doit être décomposée en éléments individuels (rue, code postal, ville, etc.)
    signin(projet.numero_fiscal, projet.reference_avis)
    within 'article.occupants' do
      click_link I18n.t('projets.visualisation.lien_edition')
    end
    fill_in :projet_adresse, with: '12 rue de la mare, 75010 Paris'
    click_button I18n.t('projets.edition.action')
    expect(page).to have_content('12 rue de la Mare, 75010 Paris')
  end

  scenario "je peux modifier les données concernant mon habitation et mon projet" do
    signin(projet.numero_fiscal, projet.reference_avis)
    within 'article.projet' do
      click_link I18n.t('projets.visualisation.lien_edition')
    end
    fill_in :demande_annee_construction, with: '1950'
    click_button I18n.t('projets.edition.action')
    expect(page).to have_content(1950)
    # TODO: tester la modification des travaux demandés
  end
end
