FactoryGirl.define do
  A_Z = ('A'..'Z').to_a

  factory :occupant do
    sequence(:nom) do |n|
      trigram = A_Z[(n / 676) % 26] + A_Z[(n / 26) % 26] + A_Z[n % 26]
      "Martin#{trigram}"
    end
    prenom 'Jean'
    civility 'mr'
    avis_imposition
  end

  factory :demandeur, parent: :occupant do
    demandeur true
    date_de_naissance '20/06/1977'
  end

  factory :declarant, parent: :occupant do
    demandeur true
    declarant true
    date_de_naissance '20/06/1977'
  end
end

