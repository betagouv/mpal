module API
  class PrestationsController < ActionController::Base
    def create
      projet = Projet.find(params[:projet_id])
      prestations_json = JSON.parse(request.body.read)
      prestations_json.each do |prestation|
        projet.prestations.build(prestation)
      end
      projet.save
      render nothing: true, status: :created
    end
  end
end
