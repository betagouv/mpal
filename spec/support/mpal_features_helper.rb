require 'support/api_particulier_helper'

def signin(numero_fiscal, reference_avis)
  visit new_session_path
  fill_in :numero_fiscal,  with: numero_fiscal
  fill_in :reference_avis, with: reference_avis
  find('.form-login .btn').click
end

def signin_for_new_projet
  signin(Fakeweb::ApiParticulier::NUMERO_FISCAL, Fakeweb::ApiParticulier::REFERENCE_AVIS)
end

def signin_for_new_projet_non_eligible
  signin(Fakeweb::ApiParticulier::NUMERO_FISCAL_NON_ELIGIBLE, Fakeweb::ApiParticulier::REFERENCE_AVIS_NON_ELIGIBLE)
end

def authenticate_as_admin_with_token
  # L'environnement est mocké car CircleCI ne permet pas d'exposer des
  # variables d'environnement lors des builds de Pull requests.
  allow(ENV).to receive(:[]).and_call_original
  allow(ENV).to receive(:[]).with('ADMIN_TOKEN').and_return('admin-test-token')

  if defined?(page) # Capybara
    page.driver.browser.set_cookie("admin_token=#{ENV['ADMIN_TOKEN']}")
    # Capybara will clear the cookies at the end of the scenario
  end

  if @request.present? && @request.cookies # Controller specs
    @request.cookies['admin_token'] = ENV['ADMIN_TOKEN']
  end
end
