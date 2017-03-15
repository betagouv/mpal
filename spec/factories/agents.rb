FactoryGirl.define do
  factory :agent do
    nom "Dupont"
    prenom "Joelle"
    username "joelledupont"
    intervenant

    trait :instructeur do
      nom 'Instructeur'
      prenom 'Agent'
      username 'agent_instructeur'
    end

    trait :operateur do
      nom 'Operateur'
      prenom 'Agent'
      username 'agent_operateur'
    end

    trait :pris do
      nom 'PRIS'
      prenom 'Agent'
      username 'agent_pris'
    end
  end
end
