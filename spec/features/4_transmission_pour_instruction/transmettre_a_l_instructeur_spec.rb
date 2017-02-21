require 'rails_helper'
require 'support/mpal_helper'
require 'support/api_particulier_helper'
require 'support/api_ban_helper'

feature "Transmettre à l'instructeur :" do
  let(:projet) { create :projet, :proposition_acceptee, :with_intervenants_disponibles }

  context "en tant que demandeur" do
    scenario "je transmet mon projet aux services instructeurs" do
      signin(projet.numero_fiscal, projet.reference_avis)
      expect(page.current_path).to eq(projet_path(projet))

      click_button I18n.t('projets.transmissions.envoi_demande')

      expect(page).to have_current_path(projet_path(projet))
      expect(page).to have_content(I18n.t('projets.transmissions.messages.succes'))
      expect(page).to have_content(I18n.t('projets.statut.transmis_pour_instruction').downcase)
    end
  end
end
