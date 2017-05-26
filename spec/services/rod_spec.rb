require 'rails_helper'
require 'support/rod_helper'

describe Rod do
	describe "#query_for" do
		let(:projet) 					 { create :projet, :with_demandeur, :with_demande }
		subject(:rod_response) { Rod.new(RodClient).query_for(projet) }

		context "en cas de succès" do
			context "si des PRIS n'existent pas " do
				it "crée les PRIS manquants" do
					expect(rod_response.pris.raison_sociale).to  	 eq "ADIL du Doubs"
					expect(rod_response.pris.adresse_postale).to 	 eq "1 chemin de Ronde du Fort Griffon 25000 Besançon"
					expect(rod_response.pris.email).to 					 	 eq "adil25@orange.fr"
					expect(rod_response.pris.phone).to 					 	 eq "03 81 61 92 41"
					expect(rod_response.pris.roles).to 					 	 include "pris"
					expect(rod_response.pris.clavis_service_id).to eq "5421"
				end
			end

			context "si un PRIS correspondant existe déjà" do
				let(:pris) { create :pris, clavis_service_id: 5421, roles: [] }
				before 		 { create :invitation, projet: projet, intervenant: pris }

				it "met à jour les informations du PRIS" do
					expect(rod_response.pris.id).to 						 	 eq pris.id
					expect(rod_response.pris.raison_sociale).to  	 eq "ADIL du Doubs"
					expect(rod_response.pris.adresse_postale).to 	 eq "1 chemin de Ronde du Fort Griffon 25000 Besançon"
					expect(rod_response.pris.email).to 					 	 eq "adil25@orange.fr"
					expect(rod_response.pris.phone).to 					 	 eq "03 81 61 92 41"
					expect(rod_response.pris.roles).to 					 	 include "pris"
					expect(rod_response.pris.clavis_service_id).to eq "5421"
				end
			end
		end

		context "en cas d'erreur" do
			before { Fakeweb::Rod.register_query_for_failure }

			it "lève une exception avec le message d'erreur" do
				expect{rod_response}.to raise_error(RodError, "Applicant's adress is not found. Check if adress is correct")
			end
		end
	end
end
