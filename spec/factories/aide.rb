FactoryGirl.define do
  factory :aide do
    sequence(:libelle) {|n| "Subvention #{n}" }
  end

  factory :projet_aide do
    projet
    aide
  end
end
