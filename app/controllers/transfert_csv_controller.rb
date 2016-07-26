class TransfertCsvController < ActionController::Base
  def create
    projet_id = params[:projet_id]
    travaux_csv = params[:fichier_travaux].open
    travaux_json = StringIO.new
    CSV2JSON.parse(travaux_csv, travaux_json)
    travaux_json.pos = 0
    API::PlansTravauxController.new.ajouter_prestations(projet_id, travaux_json)
    redirect_to projet_demande_path(projet_id: projet_id) 
  end
end
