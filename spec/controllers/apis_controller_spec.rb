require "rails_helper"


describe ApisController do
	describe "#update_state" do
		let(:projet) {create :projet, :en_cours_d_instruction}		

		context "la page affiche l'id du projet passe en params de l'url" do
			# post :update_state, params{projet_id: projet.id, statut: "transmis_pour_instruction"}
			

			it "doit changer le statut du projet vers 'transmis_pour_instruction'" do
				post :update_state, params: {
					projet_id: projet.id,
				}
				projet.reload
				expect(projet.satut).to eq "transmis_pour_instruction"
			end
		end
	end
end


