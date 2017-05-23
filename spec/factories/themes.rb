FactoryGirl.define do
  factory :theme do
    sequence(:libelle) {|n| "Theme #{n}" }
  end
end
