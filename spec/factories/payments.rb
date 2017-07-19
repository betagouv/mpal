FactoryGirl.define do
  factory :payment do
    statut :en_cours_de_montage
    action :aucune
    type_paiement :avance
    sequence(:beneficiaire) { |n| "Beneficiaire #{n}" }
    personne_morale false
  end
end
