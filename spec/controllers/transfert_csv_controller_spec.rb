require 'rails_helper'

describe TransfertCsvController do
  let(:projet) { FactoryGirl.create(:projet) }
  let(:intervenant) { FactoryGirl.create(:intervenant) }
  let(:invitation) { FactoryGirl.create(:invitation, intervenant: intervenant, projet: projet) }

  it "transfert un csv vers l'api json" do
    session[:jeton] = invitation.token
    travaux_csv = fixture_file_upload 'travaux.csv', "application/csv"
    post :create, { fichier_travaux:  travaux_csv, projet_id: projet.id }
    expect(projet.prestations.first.libelle).to eq('Chaudiere x27')
    travaux_csv.close
  end
end
