FactoryGirl.define do
  factory :user do
    sequence(:email) {|n| "prenom#{n}@site.com" }
    password "my_secret_password"
  end
end
