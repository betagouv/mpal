FactoryGirl.define do
  factory :projet do
    numero_fiscal 12
    reference_avis 15
    adresse_ligne1 '12 rue de la Mare'
    departement '75'
    code_insee '75010'
    code_postal '75010'
    email 'prenom.nom@site.com'
    nb_occupants_a_charge 0
    plateforme_id 1234

    after(:create) do |projet, evaluator|
      create_list(:demandeur, 1, projet: projet)
      create(:demande, projet: projet)
    end

    trait :with_invitation do
      after(:create) do |projet, evaluator|
        create(:invitation, projet: projet, intervenant: create(:intervenant, :operateur))
      end
    end
  end
end
