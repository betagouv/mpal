FactoryGirl.define do
  factory :prestation_choice do
    association :projet
    association :prestation

    trait(:desired)     { desired      true }
    trait(:recommended) { recommended true }
    trait(:selected)    { selected    true }
  end
end
