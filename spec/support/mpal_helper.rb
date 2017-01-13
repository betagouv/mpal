def signin(numero_fiscal, reference_avis)
  visit new_session_path
  fill_in :numero_fiscal, with: numero_fiscal
  fill_in :reference_avis, with: reference_avis
  find('.form-login .btn').click
end

def json(body)
  JSON.parse(body, symbolize_names: true)
end

def set_token_header(token)
  request.env['HTTP_AUTHORIZATION'] = "Token token=#{token}"
end
