class ApisController < ApplicationController
	skip_before_action :verify_authenticity_token, :only => [:update_state, :not_implemented]

	def not_implemented
		ret = [{erreur: "403",erreur_description: "Le token n'est pas valide"}]
		render plain: ret.to_json, status: 403
	end

	def update_state
		begin
			if (request.headers["token"]) != ENV['SECRET_SEL_API_FOR_OPAL'] || ENV['SECRET_SEL_API_FOR_OPAL'] == nil
				ret = [{erreur: "403",erreur_description: "Le token n'est pas valide"}]
				render plain: ret.to_json, status: 403
			else
				json = params[:_json]
				json.each do |dossier|
					if dossier["numero"] && /\A\d+\z/.match(dossier["numero"])
						projet = Projet.find_by(:opal_numero => dossier["numero"])
						if projet
							opalPositionLabel = dossier["position"]
							opalDatePosition = ""
							opalNewStatut = ""
							if dossier["position"] == "AGREE"
								opalNewStatut = "Subvention accordée"
							elsif dossier["position"] == "REJET"
								opalNewStatut = "Subvention rejetée"
							elsif dossier["position"] == "SANS_SUITE" || dossier["position"] == "TRAITINT"
								opalNewStatut = "Classé sans suite"
							elsif dossier["position"] == "ANNULE"
								opalNewStatut = "Subvention retiré"
							elsif dossier["position"] == "RVS_PRONONCE"
								opalNewStatut = "Subvention retiré avec reversement"
							elsif dossier["position"] == "DEMAC"
								opalNewStatut = "Demande d'acompte"
							elsif dossier["position"] == "AC_PAYE"
								opalNewStatut = "Acompte payé"
							elsif dossier["position"] == "DEMAV"
								opalNewStatut = "Demande d'avance"
							elsif dossier["position"] == "AVANCE_PAYE"
								opalNewStatut = "Avance payée"
							elsif dossier["position"] == "DEMSOLDE" || dossier["position"] == "DEMSOLDECOMPL" || dossier["position"] == "CALC_PAI"
								opalNewStatut = "Demande de solde"
							elsif dossier["position"] == "SOLDE"
								opalNewStatut = "Solde payé"
							end
							opalDatePosition = DateTime.strptime(dossier["date"].to_s.slice(0..-4), '%s')
							if opalPositionLabel != "" && opalDatePosition != "" && opalDatePosition != nil && opalNewStatut != ""
								if projet.opal_date_position != opalDatePosition || projet.opal_position_label != opalPositionLabel || projet.opal_position != opalNewStatut
									projet.update(:opal_date_position => opalDatePosition, :opal_position_label => opalNewStatut, :opal_position => opalPositionLabel)
								end
							end
						end
					end
				end
				ret = [{erreur: "202",erreur_description: "La requête a ete acceptée et son traitement est en cours"}]
				render plain: ret.to_json, status: 200
			end
		rescue
			ret = [{erreur: "422",erreur_description: "Une erreur a eu lieu côté Serveur"}]
			render plain: ret.to_json, status: 422
		end
	end
end
