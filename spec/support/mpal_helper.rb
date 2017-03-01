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

def json(body)
  JSON.parse(body, symbolize_names: true)
end

def set_token_header(token)
  request.env['HTTP_AUTHORIZATION'] = "Token token=#{token}"
end
