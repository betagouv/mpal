FactoryGirl.define do
  factory :projet do
    numero_fiscal 12
    reference_avis 15
    description "Je veux changer ma chaudiere"
    usager 'Pierre Martin'
    adresse '12 rue de la mare, 75010 Paris'
  end
end
