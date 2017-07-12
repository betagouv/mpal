FactoryGirl.define do
  factory :avis_imposition do
    numero_fiscal 12
    reference_avis 15
    annee 2015
    revenu_fiscal_reference 29880

    association :projet, strategy: :build

    factory :avis_imposition_with_occupants do
      transient do
        declarants_count 1
        occupants_a_charge_count 0
      end

      after(:build) do |avis_imposition, evaluator|
        avis_imposition.occupants << build_list(:declarant, evaluator.declarants_count,         avis_imposition: avis_imposition)
        avis_imposition.occupants << build_list(:occupant,  evaluator.occupants_a_charge_count, avis_imposition: avis_imposition)
      end
    end
  end
end
