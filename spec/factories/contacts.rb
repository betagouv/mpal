FactoryGirl.define do
  factory :contact do
    id 1
    name "Joelle Dupont"
    email "joelle.dupont@domain.tld"
    description %(Bonjour,"
      Ceci est une demande de test.
      JD
    )
    subject :other
    department "88"
  end
end
