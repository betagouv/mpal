FactoryGirl.define do
  factory :intervenant do
    sequence(:raison_sociale) {|n| "Intervenant#{n}" }
    email 'contact@urbanos.com'
    trait :operateur do
      roles ['operateur']
    end
    trait :pris do
      roles ['pris']
    end
  end
end
