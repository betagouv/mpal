FactoryGirl.define do
  factory :occupant do
    sequence(:nom) {|n| "Martin#{n}" }
    prenom 'Jean'
    civility 'mr'
    avis_imposition
  end

  factory :demandeur, parent: :occupant do
    demandeur true
    date_de_naissance '20/06/1977'
  end

  factory :declarant, parent: :occupant do
    demandeur true
    declarant true
    date_de_naissance '20/06/1977'
  end
end

