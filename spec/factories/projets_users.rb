FactoryGirl.define do
  factory :projets_user do
    association :projet
    association :user

    trait(:demandeur)  { kind "demandeur" }
    trait(:mandataire) { kind "mandataire" }
  end
end
