FactoryGirl.define do
  factory :projet do
    numero_fiscal 12
    reference_avis 15
    email 'prenom.nom@site.com'
    association :adresse_postale,   factory: [ :adresse, :rue_de_rome ]
    association :adresse_a_renover, factory: [ :adresse, :rue_de_la_mare ]

    trait :with_trusted_person do
      after(:build) do |projet|
        projet.personne = create :personne
      end
    end

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
        projet.invitations << create(:invitation, projet: projet, intervenant: operateurA, suggested: true)
        projet.invitations << create(:invitation, projet: projet, intervenant: operateurC, suggested: true)
        # B is available but not suggested
      end
    end

    trait :with_contacted_operateur do
      after(:build) do |projet|
        operateur = create(:operateur, departements: [projet.departement])
        projet.invitations << create(:invitation, projet: projet, intervenant: operateur, contacted: true)
      end
    end

    trait :with_committed_operateur do
      with_contacted_operateur
      after(:build) do |projet|
        projet.operateur = projet.contacted_operateur
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

    trait :with_selected_prestation do
      after(:build) do |projet|
        prestation = create(:prestation)
        projet.prestation_choices << create(:prestation_choice, :selected, projet: projet, prestation: prestation)
      end
    end

    trait :with_payment_registry do
      after(:build) do |projet|
        payment_registry = create(:payment_registry)
        projet.update payment_registry: payment_registry
      end
    end

    # Project states

    trait :initial do
      statut :prospect
      email nil
      annee_construction nil
      with_avis_imposition

      after(:create) do |projet, evaluator|
        projet.demandeur.update_attribute(:civility, nil)
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
      travaux_ht_amount               1111.11
      assiette_subventionnable_amount 2222.22
      travaux_ttc_amount              5555.55
      with_demandeur
      with_demande
      with_assigned_operateur
      with_selected_prestation
    end

    trait :proposition_proposee do
      statut :proposition_proposee
      with_demandeur
      with_demande
      with_assigned_operateur
      with_selected_prestation
    end

    trait :transmis_pour_instruction do
      with_demandeur
      with_demande
      with_assigned_operateur
      with_selected_prestation
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
      with_selected_prestation
      with_committed_instructeur
      with_invited_pris

      after(:build) do |projet|
        projet.statut = :en_cours_d_instruction
      end
    end
  end
end
