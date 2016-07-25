module API
  class SubventionsController < ActionController::Base
    def create
      projet = Projet.find(params[:projet_id]) 
      subventions_json = JSON.parse(request.body.read)
      subventions_json.each do |subvention|
        projet.subventions.build(subvention)
      end
      projet.save
      render nothing: true, status: :created
    end
  end
end
