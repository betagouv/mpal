FactoryGirl.define do
  factory :invitation do
    association :projet, departement: '95'
    association :intervenant, departements: [ '95' ], roles: [ :operateur ]
  end
  factory :mise_en_relation, parent: :invitation do
    association :intermediaire, factory: :intervenant
  end
end
