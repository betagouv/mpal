require 'rails_helper'
require 'support/api_particulier_helper'

describe "identification", type: :feature do
  let(:projet) { FactoryGirl.create(:projet) }
  scenario "je démarre mon projet" do
    visit new_session_path
    fill_in :numero_fiscal, with: '12'
    fill_in :reference_avis, with: '15'
    click_button I18n.t('sessions.nouvelle.action')
    expect(page).to have_content("Martin")
  end
end


