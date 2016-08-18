require 'rails_helper'

describe SessionsController do
  let(:projet) { FactoryGirl.create(:projet)}

  # tester l'authentification

  # it "quand un demandeur se connecte avec son numero fiscal, il voit la page projet en tant que demandeur" do
  #   session[:jeton] = projet.numero_fiscal
  #   puts " ZZZZZZZZZZZZ #{session[:jeton]}"
  #
  #   expect(@role_utilisateur).to eq(:demandeur)
  #   #le jeton invitation doit être vide
  # end

end
