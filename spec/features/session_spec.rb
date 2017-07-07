require 'rails_helper'
require 'support/mpal_features_helper'
require 'support/api_ban_helper'
require 'support/api_particulier_helper'

feature "Identification :" do
  context "en tant que demandeur" do
    scenario "je démarre un nouveau projet" do
      signin_for_new_projet
      expect(page).to have_current_path projet_demandeur_path(Projet.last)
    end
  end
end

feature "Réinitialisation de la session :" do
  let(:user)             { create :user }
  let(:projet)           { create :projet, :prospect, :with_invited_pris, user: user, locked_at: Time.new(2001, 2, 3, 4, 5, 6) }
  let(:operateur)        { create :operateur, departements: [projet.departement] }
  let(:invitation)       { create :invitation, projet: projet, intervenant: operateur }
  let(:agent_operateur)  { create :agent, intervenant: operateur }

  context "en tant qu'utilisateur connecté" do
    before { login_as user, scope: :user }

    scenario "je vois le lien pour se déconnecter s'il y a un projet et un message qui m'annonce que je me suis bien deconnecté(e)" do
      visit projet_path(projet)
      expect(page).to have_content("Martin")
      expect(page).to have_link(I18n.t('sessions.lien_deconnexion'))
      click_link I18n.t('sessions.lien_deconnexion')
      expect(page).to have_content(I18n.t('sessions.confirmation_deconnexion'))
    end
  end

  context "en tant qu’agent" do
    before { login_as agent_operateur, scope: :agent }

    scenario "j'ai un bouton pour me déconnecter" do
      visit dossier_path(invitation.projet)
      expect(page).to have_link(I18n.t('sessions.lien_deconnexion'))
    end
  end

  context "en tant qu’agent" do
    scenario "j'ai une notification de déconnexion" do
      visit agents_signed_out_path
      expect(page).to have_content(I18n.t('sessions.confirmation_deconnexion_clavis'))
    end
  end
end
