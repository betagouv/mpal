require 'rails_helper'
require 'support/mpal_features_helper'
require 'support/api_particulier_helper'
require 'support/api_ban_helper'

feature "Transmettre à l'instructeur :" do
  let(:projet) { create :projet, :proposition_proposee, :with_intervenants_disponibles }

  context "en tant que demandeur" do
    scenario "j'accepte la proposition et je transmets mon projet aux services instructeurs" do
      signin(projet.numero_fiscal, projet.reference_avis)
      expect(page.current_path).to eq(projet_path(projet))

      click_link I18n.t('projets.statut.bouton_accepter')

      expect(page).to have_current_path(projet_transmission_path(projet))
      click_button I18n.t('projets.transmission.envoi_demande')

      expect(page).to have_content(I18n.t('projets.transmission.messages.success'))
      expect(page).to have_content(I18n.t('projets.statut.transmis_pour_instruction').downcase)
    end
  end
end
