FactoryGirl.define do
  factory :adresse do
    ligne_1     '12 rue de la Mare'
    code_insee  '75010'
    code_postal '75010'
    ville       'Paris'
    departement '75'
    region      'Île-de-France'

    trait :rue_de_la_mare do
      ligne_1     '12 rue de la Mare'
      code_insee  '75010'
      code_postal '75010'
      ville       'Paris'
      departement '75'
      region      'Île-de-France'
    end

    trait :rue_de_rome do
      ligne_1     '65 rue de Rome'
      code_insee  '75008'
      code_postal '75008'
      ville       'Paris'
      departement '75'
      region      'Île-de-France'
    end

    trait :rue_des_brosses do
      ligne_1     '10 rue des Brosses'
      code_insee  '25000'
      code_postal '25000'
      ville       'Besançon'
      departement '25'
      region      'Bourgogne Franche-Comté'
    end
  end
end
