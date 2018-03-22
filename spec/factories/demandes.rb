FactoryGirl.define do
  factory :demande do
    projet
    annee_construction 2010
    froid true

    trait :demande_hma do
        projet
	    eligible_hma true
    end

  end
end
