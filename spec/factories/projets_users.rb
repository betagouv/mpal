FactoryGirl.define do
  factory :projets_user do
    association :projet
    association :user

    trait :demandeur do
      kind :demandeur
    end

    trait :mandataire do
      kind :mandataire
    end

    trait :revoked_mandataire do
      kind :mandataire
      revoked_at DateTime.new(1991, 02, 04)
    end
  end
end
