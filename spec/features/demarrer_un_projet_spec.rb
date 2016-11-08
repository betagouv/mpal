require 'rails_helper'
require 'support/mpal_helper'
require 'support/api_particulier_helper'
require 'support/api_ban_helper'

feature "Démarrer un projet" do
  before(:each) do
  	p Projet.count
    DatabaseCleaner[:active_record].start
    # Projet.destroy_all
    # Invitation.destroy_all
    # Occupant.destroy_all
  end

  it 'fails' do
  	puts 'fails'
  end

  let(:projet) { FactoryGirl.create(:projet) }

  scenario "depuis la page d'accueil" do
    visit root_path
    click_on I18n.t('accueil.action')
    expect(page.current_path).to eq(new_session_path)
  end

  scenario "depuis la page de connexion si je n'ai pas encore créer de projet" do
    puts "---------- projet.id before sign in #{projet.id}"
    signin(12,15)
    puts "------ current page ----- #{page.current_path}"
    puts "---------- projet.id after sign in = #{projet.id}"
    # expect(page.current_path).to eq(etape1_recuperation_infos_demarrage_projet_path(projet))
    expect(page).to have_content('Ce que nous savons de vous')
  end
end
