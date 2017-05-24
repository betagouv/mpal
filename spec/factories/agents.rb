FactoryGirl.define do
  factory :agent do
    nom "Dupont"
    prenom "Joelle"
    username "joelledupont"
    intervenant

    trait :instructeur do
      nom 'Instructeur'
      prenom 'Agent'
      sequence(:username) {|n| "agent_instructeur#{n}" }
    end

    trait :operateur do
      nom 'Operateur'
      prenom 'Agent'
      sequence(:username) {|n| "agent_operateur#{n}" }
    end

    trait :pris do
      nom 'PRIS'
      prenom 'Agent'
      sequence(:username) {|n| "agent_pris#{n}" }
    end

    trait :siege do
      nom 'Siege'
      prenom 'Agent'
      sequence(:username) {|n| "agent_siege#{n}" }
    end

    trait :dreal do
      nom 'DREAL'
      prenom 'Agent'
      sequence(:username) {|n| "agent_dreal#{n}" }
    end
    
  end
end
