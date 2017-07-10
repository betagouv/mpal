require 'rails_helper'
require 'support/mpal_features_helper'
require 'support/api_particulier_helper'
require 'support/api_ban_helper'

feature "Remplir la proposition de travaux" do
  let(:projet)            { create :projet, :en_cours }
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
    before { login_as agent_operateur, scope: :agent }

    scenario "je visualise la proposition de travaux pour m'affecter le projet" do
      visit dossier_path(projet)
      click_link I18n.t('projets.visualisation.remplir_le_projet')
      expect(page).to have_current_path(dossier_proposition_path(projet))
      expect(page).to have_content I18n.t('projets.visualisation.projet_affecte')
      expect(page).to have_field('projet_demande_attributes_annee_construction', with: '2010')
    end

    scenario "je remplis et j'enregistre une proposition de travaux'" do
      visit dossier_proposition_path(projet)
      expect(page).to have_content('Plan de financement prévisionnel')

      # Section "Logement"
      fill_in 'projet_date_de_visite', with: '28/12/2016'
      select 'Appartement', from: 'projet_type_logement'
      select '2', from: 'projet_etage'
      select 'Plus de 5', from: 'projet_nb_pieces'
      fill_in 'projet_demande_attributes_annee_construction', with: '1954'
      fill_in 'projet_surface_habitable', with: '42'
      fill_in I18n.t('helpers.label.proposition.etiquette_avant_travaux'), with: 'C'
      fill_in 'projet_consommation_avant_travaux', with: '333'

      # Section "Diagnostic opérateur"
      choose 'projet_autonomie_true'
      fill_in 'projet_niveau_gir', with: '712'
      choose 'projet_handicap_true'
      fill_in 'projet_note_degradation', with: '0,1'
      fill_in 'projet_note_insalubrite', with: '0,2'
      choose 'projet_ventilation_adaptee_true'
      choose 'projet_presence_humidite_true'
      choose 'projet_auto_rehabilitation_true'
      fill_in 'projet_remarques_diagnostic', with: 'Le diagnostic est complet.'

      # Section Types d'intervention
      check theme_1.libelle

      # Section "Description des travaux proposés"
      check "prestation_#{prestation_1.id}_desired"
      check "prestation_#{prestation_2.id}_selected"
      fill_in I18n.t('helpers.label.proposition.gain_energetique'), with: '31'
      fill_in I18n.t('helpers.label.proposition.etiquette_apres_travaux'), with: 'A'
      fill_in 'projet_consommation_apres_travaux', with: '222'

      # Section "Montant"
      fill_in_section_montant

      # Section "Financement"
      fill_in aide_1.libelle, with: '6 666,66'
      fill_in aide_2.libelle, with: '7 777,77'

      # Section "Financement personnel"
      fill_in I18n.t('helpers.label.proposition.personal_funding'), with: '8 888,88'
      fill_in I18n.t('helpers.label.proposition.loan_amount'), with: '9 999,99'

      # Section "Précisions"
      fill_in I18n.t('helpers.label.proposition.precisions_travaux'), with: 'Il faudra casser un mur.'
      fill_in I18n.t('helpers.label.proposition.precisions_financement'), with: 'Le prêt sera sans doute accordé.'

      click_on 'Enregistrer cette proposition'
      expect(page.current_path).to eq(dossier_path(projet))

      # Section "Logement"
      expect(page).to have_content('28 décembre 2016')
      expect(page).to have_content('Appartement')
      expect(page).to have_css('.etage', text: 2)
      expect(page).to have_css('.pieces', text:'Plus de 5')
      expect(page).to have_content('1954')
      expect(page).to have_content('42 m²')
      expect(page).to have_css('.etiquette_avant', text: 'C')
      expect(page).to have_css('.consommation_avant', text: '333')

      # Section "Diagnostic opérateur"
      expect(page).to have_content(I18n.t('helpers.label.diagnostic.autonomie'))
      expect(page).to have_content(I18n.t('helpers.label.diagnostic.niveau_gir') + ' : 712')
      expect(page).to have_content(I18n.t('helpers.label.diagnostic.handicap') + ' : Oui')
      expect(page).to have_content(I18n.t('helpers.label.diagnostic.note_degradation') + ' : 0,1')
      expect(page).to have_content(I18n.t('helpers.label.diagnostic.note_insalubrite') + ' : 0,2')
      expect(page).to have_content(I18n.t('helpers.label.diagnostic.ventilation_adaptee') + ' : Oui')
      expect(page).to have_content(I18n.t('helpers.label.diagnostic.presence_humidite') + ' : Oui')
      expect(page).to have_content(I18n.t('helpers.label.diagnostic.auto_rehabilitation') + ' Oui')
      expect(page).to have_content(I18n.t('helpers.label.diagnostic.remarques_diagnostic') + ' : Le diagnostic est complet.')

      # Section Types d'intervention
      expect(page).to     have_content theme_1.libelle
      expect(page).not_to have_content theme_2.libelle

      # Section "Description des travaux proposés"
      expect(page).to     have_content prestation_1.libelle
      expect(page).to     have_selector "#prestation_#{prestation_1.id}_desired"
      expect(page).not_to have_selector "#prestation_#{prestation_1.id}_recommended"
      expect(page).not_to have_selector "#prestation_#{prestation_1.id}_selected"
      expect(page).to     have_content prestation_2.libelle
      expect(page).not_to have_selector "#prestation_#{prestation_2.id}_desired"
      expect(page).not_to have_selector "#prestation_#{prestation_2.id}_recommended"
      expect(page).to     have_selector "#prestation_#{prestation_2.id}_selected"
      expect(page).not_to have_content prestation_3.libelle
      expect(page).not_to have_selector "#prestation_#{prestation_3.id}_desired"
      expect(page).not_to have_selector "#prestation_#{prestation_3.id}_recommended"
      expect(page).not_to have_selector "#prestation_#{prestation_3.id}_selected"
      expect(page).to have_content(I18n.t('helpers.label.proposition.gain_energetique'))
      expect(page).to have_css('.gain_energetique', text: 31)
      expect(page).to have_content(I18n.t('helpers.label.proposition.etiquette_apres_travaux'))
      expect(page).to have_css('.etiquette_apres', text: 'A')
      expect(page).to have_css('.consommation_apres', text: '222')

      # Section "Financement"
      expect(page).to have_content(I18n.t('helpers.label.proposition.travaux_ht_amount'))
      expect(page).to have_content('1 111,00 €')
      expect(page).to have_content(I18n.t('helpers.label.proposition.assiette_subventionnable_amount'))
      expect(page).to have_content('2 222,22 €')
      expect(page).to have_content(I18n.t('helpers.label.proposition.amo_amount'))
      expect(page).to have_content('3 333,33 €')
      expect(page).to have_content(I18n.t('helpers.label.proposition.maitrise_oeuvre_amount'))
      expect(page).to have_content('4 444,44 €')
      expect(page).to have_content(I18n.t('helpers.label.proposition.travaux_ttc_amount'))
      expect(page).to have_content('5 555,55 €')

      # Section "Financement"
      expect(page).to have_content aide_1.libelle
      expect(page).to have_content '6 666,66 €'
      expect(page).to have_content aide_2.libelle
      expect(page).to have_content '7 777,77 €'
      expect(page).to have_content I18n.t('helpers.label.proposition.public_helps_sum')
      expect(page).to have_content '14 444,43 €'

      # Section "Financement personnel"
      expect(page).to have_content I18n.t('helpers.label.proposition.personal_funding')
      expect(page).to have_content '8 888,88 €'
      expect(page).to have_content I18n.t('helpers.label.proposition.loan_amount')
      expect(page).to have_content '9 999,99 €'
      expect(page).to have_content I18n.t('helpers.label.proposition.fundings_sum')
      expect(page).to have_content '33 333,30 €'

      # Section "Précisions"
      expect(page).to have_content(I18n.t('helpers.label.proposition.precisions_travaux') + ' : Il faudra casser un mur.')
      expect(page).to have_content(I18n.t('helpers.label.proposition.precisions_financement') + ' : Le prêt sera sans doute accordé.')
    end

    context "quand je rentre des données invalides" do
      scenario "je vois un message d'erreur" do
        visit dossier_proposition_path(projet)
        fill_in 'projet_note_degradation', with: '9999'
        click_on 'Enregistrer cette proposition'
        expect(page).to have_current_path dossier_proposition_path(projet)
        expect(page).to have_content "La note de dégradation doit être comprise entre zéro et un"
      end
    end

    context "quand je ne réponds non/pas aux questions" do
      scenario "elles n'apparaissent pas dans la synthèse" do
        visit dossier_proposition_path(projet)
        fill_in 'projet_date_de_visite', with: '28/12/2016'
        fill_in_section_montant
        choose 'projet_ventilation_adaptee_false'
        click_on 'Enregistrer cette proposition'
        expect(page.current_path).to eq(dossier_path(projet))
        within('.block.projet-ope') { expect(page).not_to have_content 'Non' }
      end
    end

    scenario "upload d'un document sans label" do
      visit dossier_proposition_path(projet)
      attach_file :fichier_document, Rails.root + "spec/fixtures/Ma pièce jointe.txt"
      fill_in 'label_document', with: ''
      click_button(I18n.t('projets.proposition.action_depot_document'))

      expect(projet.documents.count).to eq(1)
      expect(page).to have_content(I18n.t('projets.proposition.messages.succes_depot_document'))
      expect(page).to have_link('Ma_pi_ce_jointe.txt', href: "/uploads/projets/#{projet.id}/Ma_pi_ce_jointe.txt")
    end

    scenario "upload d'un document avec un label" do
      visit dossier_proposition_path(projet)
      attach_file :fichier_document, Rails.root + "spec/fixtures/Ma pièce jointe.txt"
      fill_in 'label_document', with: 'Titre de propriété'
      click_button(I18n.t('projets.proposition.action_depot_document'))

      expect(projet.documents.count).to eq(1)
      expect(page).to have_content(I18n.t('projets.proposition.messages.succes_depot_document'))
      expect(page).to have_link('Titre de propriété', href: "/uploads/projets/#{projet.id}/Ma_pi_ce_jointe.txt")
    end

    scenario "upload d'un document avec erreur" do
      visit dossier_proposition_path(projet)
      click_button(I18n.t('projets.proposition.action_depot_document'))

      expect(page).to have_content(I18n.t('projets.proposition.messages.erreur_depot_document'))
    end

    context "pour une demande déjà remplie" do
      let(:projet)     { create :projet, :proposition_enregistree }
      let(:prestation) { projet.prestations.first }

      scenario "je peux modifier la proposition" do
        visit dossier_path(projet)
        within 'article.projet-ope' do
          click_link I18n.t('projets.visualisation.lien_edition')
        end
        expect(page.current_path).to eq(dossier_proposition_path(projet))
        expect(find_field("prestation_#{prestation.id}_selected")).to be_checked

        fill_in 'projet_surface_habitable', with: '42'
        uncheck "prestation_#{prestation.id}_selected"
        check   "prestation_#{prestation.id}_desired"
        fill_in aide_1.libelle, with: ''

        click_on 'Enregistrer cette proposition'
        expect(page.current_path).to eq(dossier_path(projet))
        expect(page).to have_content('42')
        expect(page).to have_content(prestation.libelle)
        expect(page).to     have_selector "#prestation_#{prestation.id}_desired"
        expect(page).not_to have_selector "#prestation_#{prestation.id}_selected"
        expect(page).not_to have_content(aide_1.libelle)
      end

      context "avec une prestation dépréciée" do
        let!(:old_unused_prestation)  { create :prestation, active: false }
        let!(:old_used_prestation)    { create :prestation, active: false }

        before { projet.prestation_choices << create(:prestation_choice, :selected, projet: projet, prestation: old_used_prestation) }

        scenario "j'ai toujours accès à cette prestation" do
          visit dossier_proposition_path(projet)
          expect(page).not_to have_content old_unused_prestation.libelle
          expect(page).to     have_content old_used_prestation.libelle
          expect(find_field("prestation_#{old_used_prestation.id}_selected")).to be_checked
        end
      end

      context "avec une aide dépréciée" do
        let!(:old_unused_aide)  { create :aide, active: false }
        let!(:old_used_aide)    { create :aide, active: false }

        before do
          projet.aides << old_used_aide
          old_used_aide.projet_aides.first.update(amount: 1111.1)
        end

        scenario "j'ai toujours accès à cette aide" do
          visit dossier_proposition_path(projet)
          expect(page).not_to have_content old_unused_aide.libelle
          expect(page).to have_content old_used_aide.libelle
          expect(find_field(old_used_aide.libelle).value).to eq '1 111,10 '
        end
      end
    end

    context "avec des attributs manquants" do
      let(:projet) { create :projet, :proposition_enregistree, travaux_ht_amount: nil}

      scenario "je suis notifié de l'erreur quand j'essaye d'envoyer ma proposition" do
        visit dossier_proposition_path(projet)
        fill_in 'projet_note_degradation', with: '1'

        click_on 'Enregistrer cette proposition'
        expect(page).to have_current_path dossier_path(projet)

        click_link 'Je soumets le projet au demandeur pour dépôt'
        expect(page).to have_content('Coût des travaux à réaliser HT doit être rempli(e)')

        within 'article.projet-ope' do
          click_link I18n.t('projets.visualisation.lien_edition')
        end
        fill_in 'projet_date_de_visite', with: '28/12/2016'
        fill_in I18n.t('helpers.label.proposition.travaux_ht_amount'), with: '1 111'
        click_on 'Enregistrer cette proposition'

        click_link 'Je soumets le projet au demandeur pour dépôt'
        expect(page).to have_no_content('Coût des travaux à réaliser HT doit être rempli(e)')
      end
    end
  end
end

private

def fill_in_section_montant
  fill_in I18n.t('helpers.label.proposition.travaux_ht_amount'),               with: '1 111'
  fill_in I18n.t('helpers.label.proposition.assiette_subventionnable_amount'), with: '2 222,22'
  fill_in I18n.t('helpers.label.proposition.amo_amount'),                      with: '3 333,33'
  fill_in I18n.t('helpers.label.proposition.maitrise_oeuvre_amount'),          with: '4 444,44'
  fill_in I18n.t('helpers.label.proposition.travaux_ttc_amount'),              with: '5 555,55'
end
