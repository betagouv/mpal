FactoryGirl.define do
  factory :payment do
    type_paiement :avance
    sequence(:beneficiaire) { |n| "Beneficiaire #{n}" }
    procuration false
    en_cours_de_montage

    # Statut
    trait :en_cours_de_montage do
      statut :en_cours_de_montage
      action :a_rediger
    end

    trait :propose do
      statut :propose
      action :a_valider
    end

    trait :demande do
      statut :demande
      action :a_instruire
    end

    trait :en_cours_d_instruction do
      statut :en_cours_d_instruction
      action :aucune
    end

    trait :paye do
      statut :paye
      action :aucune
    end
  end
end
