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

    trait :with_intervenants do
      after(:create) do |projet, evaluator|
        create(:intervenant, :operateur,   departements: [projet.departement])
        create(:intervenant, :pris,        departements: [projet.departement])
        create(:intervenant, :instructeur, departements: [projet.departement])
      end
    end

    trait :with_invited_operateur do
      after(:create) do |projet, evaluator|
        operateur = create(:intervenant, :operateur, departements: [projet.departement])
        create(:invitation, projet: projet, intervenant: operateur)
      end
    end
  end
end
