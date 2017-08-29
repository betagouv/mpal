FactoryGirl.define do
  factory :agents_projet do
    association :agent
    association :projet
  end
end

