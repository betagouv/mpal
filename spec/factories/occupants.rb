FactoryGirl.define do
  factory :occupant do
    sequence(:nom) {|n| "Martin#{n}" }
    prenom 'Jean'
    date_de_naissance '20/06/1977'
    civilite 'mr'
    projet
  end

  factory :demandeur, parent: :occupant do
    demandeur true
  end
end
