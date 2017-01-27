require 'rails_helper'
require 'support/mpal_helper'
require 'support/api_particulier_helper'
require 'support/api_ban_helper'

feature "J'ai accès aux données concernant le demandeur et son logement" do
  let(:projet) { create(:projet, :with_invitation) }

  scenario "affichage du nom du demandeur principal" do
    signin(projet.numero_fiscal, projet.reference_avis)
    visit projet_path(projet)
    expect(page).to have_content("Martin")
    # utilité et valeur apportée par ce test ?
  end

  scenario "lorsque je suis un demandeur, je vois les informations me concernant" do
    signin(projet.numero_fiscal, projet.reference_avis)
    @role_utilisateur = :demandeur
    expect(page).to have_content("Jean Martin")
    expect(page).to have_content("Total Revenu Fiscal de Référence")
  end

  scenario "je peux modifier mon numéro de téléphone" do
    signin(projet.numero_fiscal, projet.reference_avis)
    within 'article.occupants' do
      click_link I18n.t('projets.visualisation.lien_edition')
    end
    fill_in :projet_tel, with: '01 10 20 30 40'
    click_button I18n.t('projets.edition.action')
    expect(page).to have_content('01 10 20 30 40')
  end

  scenario "je peux modifier mon adresse", pending: true do
    # FIXME: l'adresse doit être décomposée en éléments individuels (rue, code postal, ville, etc.)
    signin(projet.numero_fiscal, projet.reference_avis)
    within 'article.occupants' do
      click_link I18n.t('projets.visualisation.lien_edition')
    end
    fill_in :projet_adresse, with: '12 rue de la mare, 75010 Paris'
    click_button I18n.t('projets.edition.action')
    expect(page).to have_content('12 rue de la Mare, 75010 Paris')
  end

  scenario "je peux modifier l'année de construction de mon logement" do
    signin(projet.numero_fiscal, projet.reference_avis)
    within 'article.projet' do
      click_link I18n.t('projets.visualisation.lien_edition')
    end
    fill_in :demande_annee_construction, with: '1950'
    click_button I18n.t('projets.edition.action')
    expect(page).to have_content(1950)
  end

  scenario "l'ajout d'une adresse e-mail non conforme affiche un message d'erreur", pending: true do
    signin(projet.numero_fiscal, projet.reference_avis)
    click_link I18n.t('projets.visualisation.lien_edition_projet')
    fill_in :projet_email, with: "lolo"
    click_button I18n.t('projets.edition.action')
    expect(page).to have_content(I18n.t('projets.edition_projet.messages.erreur_email_invalide'))
  end

  scenario "s'engage auprès d'un opérateur qui a été consulté" do
    skip
    # cette spec est plus précise, je suggère de la déplacer dans spec/features/choisir_un_operateur_spec.rb
    # il y a également un spc pour les invitations / même genre de tets spec/features/invitation_spec.rb
    operateur = FactoryGirl.create(:intervenant, :operateur)
    invitation = FactoryGirl.create(:invitation, projet: projet, intervenant: operateur)
    signin(projet.numero_fiscal, projet.reference_avis)
    visit projet_path(projet)
    expect(page).to have_content(invitation.intervenant.raison_sociale)
    click_link I18n.t('projets.visualisation.s_engager_avec_operateur')
    click_button I18n.t('choix_intervenants.nouveau.action')
    expect(page.current_path).to eq(projet_path(projet))
    expect(page).to have_content(I18n.t('projets.intervenants.messages.succes_choix_intervenant'))
    expect(page).not_to have_content(I18n.t('projets.visualisation.s_engager_avec_operateur'))
    within '.projet-ope' do
      expect(page).to have_content(operateur.raison_sociale)
      expect(page).to have_content(I18n.t('projets.operateur_construit_proposition', operateur: operateur.raison_sociale))
    end
  end
end
