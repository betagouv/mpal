FactoryGirl.define do
  factory :invitation do
    association :projet, :prospect
    association :intervenant, departements: [ '95' ], roles: [ :operateur ]
  end
  factory :mise_en_relation, parent: :invitation do
    association :intermediaire, factory: :intervenant
  end

  trait :mandataire do
    kind :mandataire
  end

  trait :revoked_mandataire do
    kind :mandataire
    revoked_at DateTime.new(1991, 02, 04)
  end
end
