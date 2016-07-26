module API
  class PlansTravauxController < APIController
    def create
      projet_id = params[:projet_id]
      projet = Projet.find(projet_id)
      plan_travaux_existe = projet.prestations.any?
      ajouter_prestations(projet_id, request.body)
      status = plan_travaux_existe ? :ok : :created
      render nothing: true, status: status
    end

    def ajouter_prestations(projet_id, prestations_io)
      prestations_json = JSON.parse(prestations_io.read)
      projet = Projet.find(projet_id)
      projet.prestations.destroy_all
      prestations_json.each do |prestation|
        projet.prestations.build(prestation)
      end
      projet.save
    end
  end
end
