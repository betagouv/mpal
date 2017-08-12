FactoryGirl.define do
  factory :message do
    corps_message "Ceci est un message"
    association :auteur, factory: :intervenant
    projet
  end
end

