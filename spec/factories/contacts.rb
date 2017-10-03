FactoryGirl.define do
  factory :contact do
    name "Joelle Dupont"
    email "joelle.dupont@domain.tld"
    description %(Bonjour,"
      Ceci est une demande de test.
      JD
    )
    department "88"
  end
end
