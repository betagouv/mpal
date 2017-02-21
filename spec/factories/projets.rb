FactoryGirl.define do
  factory :projet do
    numero_fiscal 12
    reference_avis 15
    adresse_ligne1 '12 rue de la Mare'
    departement '75'
    code_insee '75010'
    code_postal '75010'
    email 'prenom.nom@site.com'
    nb_occupants_a_charge 0
    plateforme_id 1234

    after(:create) do |projet, evaluator|
      create_list(:demandeur, 1, projet: projet)
      create(:demande, projet: projet)
    end

    trait :with_demande do
      after(:build) do |projet|
        projet.build_demande
      end
    end

    trait :with_intervenants_disponibles do
      after(:build) do |projet|
        create(:operateur,   departements: [projet.departement])
        create(:pris,        departements: [projet.departement])
        create(:instructeur, departements: [projet.departement])
      end
    end

    trait :with_invited_pris do
      after(:build) do |projet|
        pris = create(:pris, departements: [projet.departement])
        create(:invitation, projet: projet, intervenant: pris)
      end
    end

    trait :with_invited_operateur do
      after(:build) do |projet|
        operateur = create(:operateur, departements: [projet.departement])
        create(:invitation, projet: projet, intervenant: operateur)
      end
    end

    trait :with_committed_operateur do
      after(:build) do |projet|
        projet.operateur = create(:operateur, departements: [projet.departement])
        create(:invitation, projet: projet, intervenant: projet.operateur)
      end
    end

    trait :with_prestations do
      transient do
        prestations_count 1
      end

      after(:build) do |projet, evaluator|
        projet.prestations = Prestation.first(evaluator.prestations_count)
      end
    end

    # Project states

    trait :prospect do
      statut :prospect
    end

    trait :en_cours do
      statut :en_cours
      with_committed_operateur
    end

    trait :proposition_enregistree do
      statut :proposition_enregistree
      with_committed_operateur
      with_prestations
    end

    trait :proposition_acceptee do
      statut :proposition_acceptee
      with_committed_operateur
      with_prestations
    end

    trait :transmis_pour_instruction do
      statut :transmis_pour_instruction
      with_committed_operateur
      with_prestations

      after(:build) do |projet|
        projet.operateur = create(:operateur, departements: [projet.departement])
        projet.invitations << create(:invitation, intermediaire: projet.operateur, intervenant: create(:instructeur))
      end
    end

    trait :en_cours_d_instruction do
      statut :en_cours_d_instruction
      with_committed_operateur
      with_prestations

      after(:build) do |projet|
        projet.operateur = create(:operateur, departements: [projet.departement])
        projet.invitations << create(:invitation, intermediaire: projet.operateur, intervenant: create(:instructeur))
      end
    end
  end
end
