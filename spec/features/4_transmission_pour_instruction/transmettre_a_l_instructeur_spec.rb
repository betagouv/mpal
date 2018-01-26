require 'rails_helper'
require 'support/mpal_features_helper'
require 'support/api_particulier_helper'
require 'support/api_ban_helper'
require 'support/rod_helper'

feature "Transmettre à l'instructeur :" do

  context "avant que le dossier ne soit transmis" do
    let(:projet) { create :projet, :proposition_proposee, :with_intervenants_disponibles, :with_invited_instructeur }
    let(:instructeur) { projet.invited_instructeur }

    context "en tant que demandeur" do
      scenario "j'accepte la proposition et je transmets mon projet aux services instructeurs" do
        login_as projet.demandeur_user, scope: :user

        visit projet_path(projet)
        expect(page).to have_current_path(projet_path(projet))
        click_link I18n.t('projets.transmission.bouton_continuer')

        expect(page).to have_current_path(projet_transmission_path(projet))
        check I18n.t('projets.proposition.confirmation')
        click_button I18n.t('projets.transmission.envoi_demande')

        expect(page).to have_content(I18n.t('projets.transmission.messages.success', instructeur: instructeur.raison_sociale))
        expect(page).to have_content(I18n.t('projets.statut.transmis_pour_instruction').downcase)
      end
    end
  end

  context "après transmission aux services instructeurs" do
    context "pour tous les intervenants" do
      let(:projet) { create :projet, :transmis_pour_instruction, :with_intervenants_disponibles, :with_invited_instructeur }

      shared_examples "le dossier n'est plus modifiable" do
        specify do
          within 'article.occupants' do
            expect(page).not_to have_content I18n.t('projets.visualisation.lien_edition')
          end
          within 'article.projet' do
            expect(page).not_to have_content I18n.t('projets.visualisation.lien_edition')
          end
        end
      end

      context "en tant que demandeur" do
        before do
          login_as projet.demandeur_user, scope: :user
          visit projet_path(projet.id)
        end
        it_behaves_like "le dossier n'est plus modifiable"
      end

      context "en tant qu'opérateur" do
        let(:agent_operateur) { create :agent, intervenant: projet.operateur }
        before do
          Fakeweb::Rod.list_department_intervenants_helper
          login_as agent_operateur, scope: :agent
          visit dossier_path(projet.id)
        end
        it_behaves_like "le dossier n'est plus modifiable"
      end

      context "en tant qu'instructeur" do
        let(:agent_instructeur) { create :agent, intervenant: projet.invited_instructeur }
        before do
          Fakeweb::Rod.list_department_intervenants_helper
          login_as agent_instructeur, scope: :agent
          visit dossier_path(projet.id)
        end
        it_behaves_like "le dossier n'est plus modifiable"
      end
    end
  end
end
