FactoryGirl.define do
  factory :projet do
    numero_fiscal 12
    reference_avis 15
    email 'prenom.nom@site.com'
    annee_construction 1975
    association :adresse_postale,   factory: [ :adresse, :rue_de_rome ]
    association :adresse_a_renover, factory: [ :adresse, :rue_de_la_mare ]

    trait :with_avis_imposition do
      transient do
        declarants_count 1
        occupants_a_charge_count 0
      end

      after(:build) do |projet, evaluator|
        projet.avis_impositions << build(:avis_imposition_with_occupants,
          projet:                   projet,
          numero_fiscal:            projet.numero_fiscal,
          reference_avis:           projet.reference_avis,
          declarants_count:         evaluator.declarants_count,
          occupants_a_charge_count: evaluator.occupants_a_charge_count)
      end
    end

    trait :with_demandeur do
      with_avis_imposition
      declarants_count 2
      occupants_a_charge_count 2

      after(:build) do |projet|
        projet.avis_impositions.first.occupants.first.demandeur = true
      end
    end

    trait :with_demande do
      after(:build) do |projet|
        create(:demande, projet: projet)
      end
    end

    trait :with_intervenants_disponibles do
      after(:build) do |projet|
        create(:operateur,   departements: [projet.departement])
        create(:pris,        departements: [projet.departement])
        create(:instructeur, departements: [projet.departement])
      end
    end

    trait :with_suggested_operateurs do
      after(:build) do |projet|
        operateurA = create(:operateur, departements: [projet.departement])
        operateurB = create(:operateur, departements: [projet.departement])
        operateurC = create(:operateur, departements: [projet.departement])
        projet.suggested_operateurs = [operateurA, operateurC]
        # B is available but not suggested
      end
    end

    trait :with_invited_operateur do
      after(:build) do |projet|
        operateur = create(:operateur, departements: [projet.departement])
        projet.invitations << create(:invitation, projet: projet, intervenant: operateur)
      end
    end

    trait :with_committed_operateur do
      with_invited_operateur
      after(:build) do |projet|
        projet.operateur = projet.invited_operateur
      end
    end

    trait :with_assigned_operateur do
      with_committed_operateur
      after(:build) do |projet|
        projet.agent_operateur = create(:agent, :operateur, intervenant: projet.operateur)
      end
    end

    trait :with_invited_instructeur do
      after(:build) do |projet|
        instructeur = create(:instructeur, departements: [projet.departement])
        projet.invitations << create(:invitation, projet: projet, intervenant: instructeur)
      end
    end

    trait :with_committed_instructeur do
      with_invited_instructeur
      after(:build) do |projet|
        projet.agent_instructeur = create(:agent, :instructeur, intervenant: projet.invited_instructeur)
      end
    end

    trait :with_invited_pris do
      after(:build) do |projet|
        pris = create(:pris, departements: [projet.departement])
        projet.invitations << create(:invitation, projet: projet, intervenant: pris)
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

    trait :initial do
      statut :prospect
      email nil
      annee_construction nil
      with_avis_imposition

      after(:create) do |projet, evaluator|
        projet.demandeur_principal.update_attribute(:civilite, nil)
      end
    end

    trait :prospect do
      statut :prospect
      with_demandeur
      with_demande
      with_intervenants_disponibles
    end

    trait :en_cours do
      statut :en_cours
      with_demandeur
      with_demande
      with_committed_operateur
    end

    trait :proposition_enregistree do
      statut :proposition_enregistree
      date_de_visite DateTime.new(2016, 12, 28)
      with_demandeur
      with_demande
      with_assigned_operateur
      with_prestations
    end

    trait :proposition_proposee do
      statut :proposition_proposee
      with_demandeur
      with_demande
      with_assigned_operateur
      with_prestations
    end

    trait :transmis_pour_instruction do
      with_demandeur
      with_demande
      with_assigned_operateur
      with_prestations
      with_invited_instructeur

      after(:build) do |projet|
        projet.statut = :transmis_pour_instruction
      end
    end

    trait :en_cours_d_instruction do
      opal_numero 4567
      opal_id 8910
      with_demandeur
      with_demande
      with_assigned_operateur
      with_prestations
      with_committed_instructeur
      with_invited_pris

      after(:build) do |projet|
        projet.statut = :en_cours_d_instruction
      end
    end
  end
end
