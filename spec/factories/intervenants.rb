FactoryGirl.define do
  factory :intervenant do
    sequence(:raison_sociale) {|n| "Intervenant#{n}" }
    email 'contact@urbanos.com'
    departements ['75']

    factory :operateur do
      sequence(:raison_sociale) {|n| "Operateur#{n}" }
      roles ['operateur']
    end

    factory :pris do
      sequence(:raison_sociale) {|n| "Pris#{n}" }
      roles ['pris']
    end

    factory :instructeur do
      sequence(:raison_sociale) {|n| "Instructeur#{n}" }
      roles ['instructeur']
    end

    factory :siege do
      sequence(:raison_sociale) {|n| "Siege#{n}" }
      roles ['siege']
    end

    factory :dreal do
      sequence(:raison_sociale) {|n| "Dreal#{n}" }
      roles ['dreal']
    end
  end
end
