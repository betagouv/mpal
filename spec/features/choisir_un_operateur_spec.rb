require 'rails_helper'
require 'support/mpal_helper'
require 'support/api_particulier_helper'
require 'support/api_ban_helper'

feature "choisir un opérateur" do
  scenario "déjà invité" do
    invitation = FactoryGirl.create(:invitation) 
    projet = invitation.projet
    operateur = invitation.intervenant
    projet.operateur = operateur
    projet.save

    signin(projet.numero_fiscal, projet.reference_avis)
    visit projet_intervenants_path(projet)

  end
end

