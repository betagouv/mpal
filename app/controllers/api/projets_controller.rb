module API
  class ProjetsController < APIController
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


  end
end
