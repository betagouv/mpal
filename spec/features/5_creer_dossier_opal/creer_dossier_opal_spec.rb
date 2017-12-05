require 'rails_helper'
require 'support/mpal_features_helper'
require 'support/opal_helper'

feature "Créer le dossier dans Opal" do
  let(:projet) { create :projet, statut }

  context "en tant qu'agent instructeur" do
    let(:instructeur) { projet.intervenants.instructeur.first }
    let(:agent_instructeur) { create :agent, intervenant: instructeur }
    before { login_as agent_instructeur, scope: :agent }

    context "avant que le dossier ne soit transmis" do
      let(:statut) { :transmis_pour_instruction }

      scenario "je peux créer un dossier Opal depuis la page projet" do
        visit dossier_path(projet)
        click_button I18n.t('projets.creation_opal.titre_creation_opal')
        expect(page).to have_current_path dossier_path(projet)
        expect(page).to have_content(I18n.t("projets.creation_opal.messages.succes", id_opal: "09500840"))

        visit dossiers_path
        within "#projet_#{projet.id}" do
          expect(page).to have_content(I18n.t("projets.statut.en_cours_d_instruction"))
          expect(page).to have_content("09500840")
        end
      end

      context "quand la création du dossier échoue" do
        before { Fakeweb::Opal.register_create_dossier_failure }

        scenario "je reçois un message d'erreur" do
          visit dossier_path(projet)
          click_button I18n.t('projets.creation_opal.titre_creation_opal')

          expect(page).to have_current_path dossier_path(projet)
          expect(page).to have_content("Une erreur est survenue lors de la creation du dossier dans Opal : Unprocessable Entity (422)")
        end
      end
    end

    context "une fois que le dossier est transmis dans Opal" do
      let(:statut) { :en_cours_d_instruction }

      scenario "je peux accéder au dossier à partir du numéro envoyé à Opal" do
        visit dossier_path(dossier_id: projet.numero_plateforme)
        expect(page.current_path).to eq dossier_path(dossier_id: projet.numero_plateforme)
        expect(page).to have_content I18n.t('projets.statut.en_cours_d_instruction').downcase
      end
    end
  end
end
