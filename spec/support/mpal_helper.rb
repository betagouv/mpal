def authenticate(object)
  if object.is_a? Integer
    authenticate_as_project object
  elsif object.is_a? User
    authenticate_as_user object
  elsif object.is_a? Agent
    authenticate_as_user agent
  end
end

def authenticate_as_project(project_id)
  session[:project_id] = project_id
end

def authenticate_as_user(user)
  if user.nil?
    allow(request.env["warden"]).to receive(:authenticate!).and_throw(:warden, { scope: :user })
  else
    allow(request.env["warden"]).to receive(:authenticate!).and_return(user)
  end
  allow(controller).to receive(:current_user).and_return(user)
end

def authenticate_as_agent(agent)
  if agent.nil?
    allow(request.env["warden"]).to receive(:authenticate!).and_throw(:warden, { scope: :agent })
  else
    allow(request.env["warden"]).to receive(:authenticate!).and_return(agent)
  end
  allow(controller).to receive(:current_agent).and_return(agent)
end

def json(body)
  JSON.parse(body, symbolize_names: true)
end

def set_token_header(token)
  request.env['HTTP_AUTHORIZATION'] = "Token token=#{token}"
end
