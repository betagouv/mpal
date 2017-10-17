FactoryGirl.define do
  factory :occupant do
    sequence(:nom) do |n|
      a_z = ('A'..'Z').to_a
      trigram = a_z[(n / 676) % 26] + a_z[(n / 26) % 26] + a_z[n % 26]
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

