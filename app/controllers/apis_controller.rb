class ApisController < ApplicationController
	
	skip_before_action :verify_authenticity_token, :only => [:update_state]

	def update_state
		begin
			if (request.headers["token"]) != ENV['SECRET_SEL_API_FOR_OPAL'] || ENV['SECRET_SEL_API_FOR_OPAL'] == nil
				render json: {
					status: 403,
					message: "Le token n'est pas valide"
				}.to_json and return
			else


				json = request.raw_post
				Rails.logger.debug(json)


				json.each do |dossier|
					if dossier["numero"] && /\A\d+\z/.match(dossier["numero"])

						projet = Projet.find_by(:opal_numero => dossier["numero"])
						if projet
							opalPosition = dossier["position"]
							opalPositionLabel = dossier["position"]
							opalDatePosition = ""

							begin
								opalDatePosition = DateTime.strptime(dossier["date"].to_s, '%s')
							rescue
								opalDatePosition = ""
							end

							if opalPositionLabel != "" && opalDatePosition != "" && opalDatePosition != nil

								if projet.opal_position != opalPosition || projet.opal_date_position != opalDatePosition || projet.opal_position_label != opalPositionLabel
									projet.update(:opal_position => opalPosition, :opal_date_position => opalDatePosition, :opal_position_label => opalPosition)
								end
							end
						end
					end
				end
				render json: {
					status: 202,
					message: "La requête a ete acceptée et son traitement est en cours"
				}.to_json and return
			end

		rescue
			render json: {
				status: 412,
				message: "Une erreur a eu lieu côté Serveur"
			}.to_json and return
		end
	end
end
