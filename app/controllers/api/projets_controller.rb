module API
  class ProjetsController < ActionController::Base
    protect_from_forgery with: :null_session
    before_action :authenticate

    def show
      begin
        projet = Projet.find(params[:id])
        render json: projet
      rescue
        render json: { error: 'not found', reason: 'Projet not found' }.to_json, status: 404
      end
    end

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
