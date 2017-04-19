FactoryGirl.define do
  factory :aide do
    libelle "Subvention truc"
  end

  factory :projet_aide do
    projet
    aide
  end
end
