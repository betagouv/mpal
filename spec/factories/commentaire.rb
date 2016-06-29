FactoryGirl.define do
  factory :commentaire do
    corps_message 'Ceci est un commentaire'
    association :auteur, factory: :intervenant
    projet
  end
end
