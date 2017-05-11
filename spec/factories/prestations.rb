FactoryGirl.define do
  factory :prestation do
    sequence(:libelle) {|n| "Prestation #{n}" }
  end
end
