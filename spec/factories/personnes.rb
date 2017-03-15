FactoryGirl.define do
  factory :personne do
    civilite 'mr'
    prenom 'Augustus'
    nom 'Procrastinatus'
    tel '0610203040'
    email 'augustus.procrastinatus@palatin.it'
    lien_avec_demandeur 'Neveu'
  end
end

