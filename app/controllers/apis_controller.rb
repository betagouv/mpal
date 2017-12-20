class ApisController < ApplicationController

	skip_before_action :verify_authenticity_token, :only => [:update_state]

	def update_state

		# e3b0c44298fc1c149afbf4c8796fb92427ae41e42gas49b934ca495991b7852b855

		# check if token access or some kind of security
		# check if projet de id exist
		# update projet
		# send 200 if okay

		# @page_heading = params

		if (params["security_key"]) != "e3b0c44298fc1c149afbf4c8796fb92427ae41e42gas49b934ca495991b7852b855"
			render json: {
				status: 403,
				message: "Acces refuse"
			}.to_json and return
		end

		@projet = Projet.find_by_id(params["id_dossier"])

		if @projet != nil

			opalPosition = ""
			opalDatePosition = params["pos_date"]

			if params["pos_code"] == "10058"
				opalPosition = "En cours d'instruction"

			elsif params["pos_code"] == "8"
				opalPosition = "Accorde"

			elsif params["pos_code"] == "10"
				opalPosition = "Rejete"

			elsif params["pos_code"] == "10060"
				opalPosition = "Classe sans suite"

			elsif params["pos_code"] == "10055"
				opalPosition = "Aide retiree"

			elsif params["pos_code"] == "10072"
				opalPosition = "Aide retiree avec reversement"

			elsif params["pos_code"] == "10015"
				opalPosition = "Acompte Deposee en attente d'instruction"

			elsif params["pos_code"] == "10053"
				opalPosition = "Acompte Payee"

			elsif params["pos_code"] == "10075"
				opalPosition = "Avance Deposee en attente d'instruction"

			elsif params["pos_code"] == "10076"
				opalPosition = "Avance Payee"

			elsif params["pos_code"] == "10016"
				opalPosition = "Solde Deposee en attente d'instruction"

			elsif params["pos_code"] == "10056"
				opalPosition = "Demande solde supplementaire (???)"

			elsif params["pos_code"] == "10033"
				opalPosition = "Solde Payee"

			else
				render json: {
					status: 202,
					message: "Nothing updated Sir"
				}.to_json and return
			end			

			@projet.update(:position_opal => opalPosition) #prendre positon envoye par Opal
			@projet.update(:date_position_opal => opalDatePosition) #prendre date envoye par Opal

			# render json: @projet.to_json and return

			render json: {
				status: 200,
				message: "Well updated Sir"
			}.to_json and return
		else
			render json: {
				status: 404,
				message: "Dossier non trouve Sir"
			}.to_json and return
		end
	end

	private

end
