FactoryGirl.define do
  factory :intervenant do
    sequence(:raison_sociale) {|n| "Intervenant#{n}" }
    email 'contact@urbanos.com'
    trait :operateur do
      sequence(:raison_sociale) {|n| "Operateur#{n}" }
      roles ['operateur']
    end
    trait :pris do
      sequence(:raison_sociale) {|n| "Pris#{n}" }
      roles ['pris']
    end
    trait :instructeur do
      sequence(:raison_sociale) {|n| "Instructeur#{n}" }
      roles ['instructeur']
    end
  end
end
