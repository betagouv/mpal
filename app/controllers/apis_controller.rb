class ApisController < ApplicationController
	
	skip_before_action :verify_authenticity_token, :only => [:update_state]

	def update_state
		begin
			if (request.headers["token"]) != ENV['SECRET_SEL_API_FOR_OPAL'] || ENV['SECRET_SEL_API_FOR_OPAL'] == nil
				ret = {
					status: 403,
					message: "Le token n'est pas valide"
				}
				render json: ret, status: 403
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
								opalNewStatut = "Aide accordée"
							end

							if dossier["position"] == "REJET"
								opalNewStatut = "Aide rejetée"
							end

							if dossier["position"] == "TRAITINT"
								opalNewStatut = "Traitement interrompu"
							end

							if dossier["position"] == "SANS_SUITE"
								opalNewStatut = "Classé sans suite"
							end

							if dossier["position"] == "ANNULE"
								opalNewStatut = "Annulé"
							end

							if dossier["position"] == "RVS_PRONONCE"
								opalNewStatut = "Reversement prononcé"
							end

							
							begin
								opalDatePosition = DateTime.strptime(dossier["date"].to_s.slice(0..-4), '%s')
							rescue
								opalDatePosition = ""
							end


							if opalPositionLabel != "" && opalDatePosition != "" && opalDatePosition != nil && opalNewStatut != ""

								if projet.opal_date_position != opalDatePosition || projet.opal_position_label != opalPositionLabel || projet.opal_position != opalNewStatut
									projet.update(:opal_date_position => opalDatePosition, :opal_position_label => opalNewStatut, :opal_position => opalPositionLabel)
								end
							end
						end
					end
				end

				ret = {
					status: 202,
					message: "La requête a ete acceptée et son traitement est en cours" 
				}
				render json: ret, status: 202
			end

		rescue
			ret = {
				status: 422,
				message: "Une erreur a eu lieu côté Serveur" 
			}
			render json: ret, status: 422
		end
	end
end
