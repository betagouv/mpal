FactoryGirl.define do
  factory :aide do
    libelle "Subvention truc"
    type_aide
  end

  factory :type_aide do
    libelle "Subventions"
  end

  factory :projet_aide do
    projet
    aide
  end
end
