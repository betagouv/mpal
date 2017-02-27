def signin(numero_fiscal, reference_avis)
  visit new_session_path
  fill_in :numero_fiscal, with: numero_fiscal
  fill_in :reference_avis, with: reference_avis
  find('.form-login .btn').click
end

def authenticate_as_particulier(numero_fiscal)
  session[:numero_fiscal] = numero_fiscal
end

def authenticate_as_agent(agent)
  if agent.nil?
    allow(request.env['warden']).to receive(:authenticate!).and_throw(:warden, {:scope => :agent})
    allow(controller).to receive(:current_agent).and_return(nil)
  else
    allow(request.env['warden']).to receive(:authenticate!).and_return(agent)
    allow(controller).to receive(:current_agent).and_return(agent)
  end
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

def json(body)
  JSON.parse(body, symbolize_names: true)
end

def set_token_header(token)
  request.env['HTTP_AUTHORIZATION'] = "Token token=#{token}"
end
