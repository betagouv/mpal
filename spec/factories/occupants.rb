FactoryGirl.define do
  factory :occupant do
    nom 'Martin'
    prenom 'Jean'
    date_de_naissance '20/06/1977'
    projet
  end

  factory :demandeur, parent: :occupant do
    demandeur true
  end

end 
