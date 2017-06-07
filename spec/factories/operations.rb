FactoryGirl.define do
  factory :operation do
    sequence(:libelle)   { |n| "Operation #{n}" }
    sequence(:code_opal) { |n| "#{n}" }
  end
end
