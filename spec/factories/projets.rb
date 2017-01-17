FactoryGirl.define do
  factory :projet do
    numero_fiscal 12
    reference_avis 15
    adresse_ligne1 '12 rue de la Mare'
    departement '75'
    code_insee '75010'
    code_postal '75010'
    email 'jean.durand@caramail.com'
    after(:create) do |projet, evaluator|
      create_list(:demandeur, 1, projet: projet)
      create(:demande, projet: projet)
    end
  end
end
