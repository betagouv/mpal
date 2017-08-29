FactoryGirl.define do
  factory :message do
    association :auteur, factory: :agent
    projet
    corps_message "Ceci est un message"
  end
end

