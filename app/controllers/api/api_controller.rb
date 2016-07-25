module API
  class APIController < ActionController::Base
    protect_from_forgery with: :null_session
    before_action :authenticate

    protected
    def authenticate
      authenticate_token || render_interdit
    end

    def authenticate_token
      authenticate_with_http_token do |token, options|
        token == 'test'
      end
    end

    def render_interdit
      self.headers['WWW-authenticate'] = 'Token'
      render json: { error: 'unauthorized', reason: "Access forbidden to this API" }.to_json, status: 401
    end
  end
end

