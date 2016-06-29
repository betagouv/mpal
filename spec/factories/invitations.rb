FactoryGirl.define do
  factory :invitation do
    projet
    intervenant
  end
  factory :mise_en_relation, parent: :invitation do
    association :intermediaire, factory: :intervenant
  end
end
