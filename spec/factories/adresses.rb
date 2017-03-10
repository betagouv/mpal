FactoryGirl.define do
  factory :adresse do
    ligne_1     '12 rue de la Mare'
    code_insee  '75010'
    code_postal '75010'
    ville       'Paris'
    departement '75'

    trait :rue_de_la_mare do
      ligne_1     '12 rue de la Mare'
      code_insee  '75010'
      code_postal '75010'
      ville       'Paris'
      departement '75'
    end

    trait :rue_de_rome do
      ligne_1     '65 rue de Rome'
      code_insee  '75008'
      code_postal '75008'
      ville       'Paris'
      departement '75'
    end
  end
end
