require 'rails_helper'
require 'support/mpal_helper'
require 'support/opal_helper'

feature "creer dossier dans opal" do
  let(:projet) {            create :projet, statut: :transmis_pour_instruction }
  let(:instructeur) {       create :intervenant, :instructeur }
  let(:invitation) {        create :invitation, intervenant: instructeur }

  context "en tant qu'agent instructeur" do
    let(:agent_instructeur) { create :agent, intervenant: instructeur }
    before { login_as agent_instructeur, scope: :agent }

    scenario "je peux créer un dossier OPAL depuis la page projet" do
      visit dossier_path(projet)
      click_button I18n.t('projets.creation_opal.titre_creation_opal')
      expect(page).to have_content(I18n.t("projets.creation_opal.messages.succes", id_opal: "09500840"))

      visit dossiers_path
      within "#projet_#{projet.id}" do
        expect(page).to have_content(I18n.t("projets.statut.en_cours_d_instruction"))
        expect(page).to have_content("09500840")
      end
    end
  end
end
