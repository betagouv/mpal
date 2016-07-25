module API
  class SubventionsController < ActionController::Base
    def create
      projet = Projet.find(params[:projet_id]) 
      plan_financements_existe = projet.subventions.any?
      projet.subventions.destroy_all
      subventions_json = JSON.parse(request.body.read)
      subventions_json.each do |subvention|
        projet.subventions.build(subvention)
      end
      projet.save
      status = plan_financements_existe ? :ok : :created
      render nothing: true, status: status
    end
  end
end
