module API
  class PrestationsController < APIController
    def create
      projet = Projet.find(params[:projet_id])
      plan_travaux_existe = projet.prestations.any?
      projet.prestations.destroy_all
      prestations_json = JSON.parse(request.body.read)
      prestations_json.each do |prestation|
        projet.prestations.build(prestation)
      end
      projet.save
      status = plan_travaux_existe ? :ok : :created
      render nothing: true, status: status
    end
  end
end
