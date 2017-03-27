FactoryGirl.define do
  factory :avis_imposition do
    numero_fiscal 12
    reference_avis 15
    annee 2015

    association :projet, strategy: :build

    factory :avis_imposition_with_occupants do
      transient do
        demandeurs_count 1
        occupants_a_charge_count 0
      end

      after(:create) do |avis_imposition, evaluator|
        create_list(:demandeur, evaluator.demandeurs_count, avis_imposition: avis_imposition)
        create_list(:occupant, evaluator.occupants_a_charge_count, avis_imposition: avis_imposition)
      end
    end
  end
end
