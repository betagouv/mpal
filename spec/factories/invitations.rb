FactoryGirl.define do
  factory :invitation do
    association :projet, :prospect
    association :intervenant, departements: [ '95' ], roles: [ :operateur ]
  end
  factory :mise_en_relation, parent: :invitation do
    association :intermediaire, factory: :intervenant
  end
end
