FactoryGirl.define do
  factory :operation do
    sequence(:name)      { |n| "Operation #{n}" }
    sequence(:code_opal) { |n| "#{n}" }
  end
end
