# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20180319104832) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "adresses", id: :serial, force: :cascade do |t|
    t.decimal "latitude", precision: 10, scale: 6
    t.decimal "longitude", precision: 10, scale: 6
    t.string "ligne_1", null: false
    t.string "code_insee", null: false
    t.string "code_postal", null: false
    t.string "ville", null: false
    t.string "departement", limit: 10, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "region", default: "", null: false
  end

  create_table "agents", id: :serial, force: :cascade do |t|
    t.string "username", null: false
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet "current_sign_in_ip"
    t.inet "last_sign_in_ip"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "nom"
    t.string "prenom"
    t.integer "intervenant_id"
    t.string "clavis_id"
    t.boolean "admin", default: false, null: false
    t.index ["clavis_id"], name: "index_agents_on_clavis_id"
    t.index ["intervenant_id"], name: "index_agents_on_intervenant_id"
    t.index ["username"], name: "index_agents_on_username", unique: true
  end

  create_table "agents_projets", id: :serial, force: :cascade do |t|
    t.integer "agent_id"
    t.integer "projet_id"
    t.datetime "last_viewed_at"
    t.datetime "last_read_messages_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["agent_id"], name: "index_agents_projets_on_agent_id"
    t.index ["projet_id"], name: "index_agents_projets_on_projet_id"
  end

  create_table "aides", id: :serial, force: :cascade do |t|
    t.string "libelle"
    t.boolean "active", default: true, null: false
    t.boolean "public", default: true, null: false
  end

  create_table "avis_impositions", id: :serial, force: :cascade do |t|
    t.string "numero_fiscal"
    t.string "reference_avis"
    t.integer "annee"
    t.integer "revenu_fiscal_reference"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "projet_id"
    t.string "declarant_1"
    t.string "declarant_2"
    t.integer "nombre_personnes_charge"
    t.index ["projet_id"], name: "index_avis_impositions_on_projet_id"
  end

  create_table "contacts", id: :serial, force: :cascade do |t|
    t.string "name", limit: 128, default: "", null: false
    t.string "email", limit: 80, default: "", null: false
    t.string "phone", limit: 20, default: "", null: false
    t.string "subject", limit: 80, default: "", null: false
    t.text "description"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "department"
    t.string "numero_plateforme"
    t.string "sender_type"
    t.bigint "sender_id"
    t.index ["name", "email"], name: "index_contacts_on_name_and_email"
    t.index ["sender_type", "sender_id"], name: "index_contacts_on_sender_type_and_sender_id"
  end

  create_table "demandes", id: :serial, force: :cascade do |t|
    t.integer "projet_id"
    t.boolean "froid"
    t.boolean "probleme_deplacement"
    t.boolean "changement_chauffage"
    t.boolean "adaptation_salle_de_bain"
    t.boolean "accessibilite"
    t.boolean "ptz"
    t.integer "annee_construction"
    t.text "complement"
    t.text "autre"
    t.boolean "hospitalisation"
    t.boolean "travaux_fenetres"
    t.boolean "travaux_isolation"
    t.boolean "travaux_chauffage"
    t.boolean "travaux_adaptation_sdb"
    t.boolean "travaux_monte_escalier"
    t.boolean "travaux_amenagement_ext"
    t.text "travaux_autres"
    t.boolean "date_achevement_15_ans"
    t.boolean "arrete", default: false, null: false
    t.boolean "saturnisme", default: false, null: false
    t.boolean "travaux_isolation_murs"
    t.boolean "travaux_isolation_combles"
    t.boolean "prime_hma"
    t.boolean "type_logement"
    t.boolean "devis_rge"
    t.boolean "eligible_hma", default: false, null: false
    t.boolean "seul", default: false, null: false
    t.index ["projet_id"], name: "index_demandes_on_projet_id"
  end

  create_table "documents", id: :serial, force: :cascade do |t|
    t.string "label"
    t.string "fichier"
    t.integer "projet_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "type_piece", default: "", null: false
    t.string "category_type"
    t.bigint "category_id"
    t.index ["category_type", "category_id"], name: "index_documents_on_category_type_and_category_id"
    t.index ["projet_id"], name: "index_documents_on_projet_id"
  end

  create_table "evenements", id: :serial, force: :cascade do |t|
    t.integer "projet_id"
    t.string "label"
    t.datetime "quand"
    t.string "producteur_type"
    t.integer "producteur_id"
    t.index ["producteur_type", "producteur_id"], name: "index_evenements_on_producteur_type_and_producteur_id"
    t.index ["projet_id"], name: "index_evenements_on_projet_id"
  end

  create_table "intervenants", id: :serial, force: :cascade do |t|
    t.string "raison_sociale"
    t.string "adresse_postale"
    t.string "themes", array: true
    t.string "departements", array: true
    t.string "email", null: false
    t.string "roles", array: true
    t.text "informations"
    t.string "clavis_service_id"
    t.string "phone", default: "", null: false
    t.index ["clavis_service_id"], name: "index_intervenants_on_clavis_service_id"
    t.index ["departements"], name: "index_intervenants_on_departements", using: :gin
    t.index ["roles"], name: "index_intervenants_on_roles", using: :gin
    t.index ["themes"], name: "index_intervenants_on_themes", using: :gin
  end

  create_table "intervenants_operations", id: :serial, force: :cascade do |t|
    t.integer "intervenant_id"
    t.integer "operation_id"
    t.index ["intervenant_id"], name: "index_intervenants_operations_on_intervenant_id"
    t.index ["operation_id"], name: "index_intervenants_operations_on_operation_id"
  end

  create_table "invitations", id: :serial, force: :cascade do |t|
    t.integer "projet_id"
    t.integer "intervenant_id"
    t.integer "intermediaire_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean "suggested", default: false, null: false
    t.boolean "contacted", default: false, null: false
    t.string "kind", default: "", null: false
    t.datetime "revoked_at"
    t.index ["intermediaire_id"], name: "index_invitations_on_intermediaire_id"
    t.index ["intervenant_id"], name: "index_invitations_on_intervenant_id"
    t.index ["projet_id"], name: "index_invitations_on_projet_id"
  end

  create_table "messages", id: :serial, force: :cascade do |t|
    t.integer "projet_id"
    t.string "auteur_type"
    t.integer "auteur_id"
    t.text "corps_message"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["auteur_type", "auteur_id"], name: "index_messages_on_auteur_type_and_auteur_id"
    t.index ["projet_id"], name: "index_messages_on_projet_id"
  end

  create_table "occupants", id: :serial, force: :cascade do |t|
    t.string "nom"
    t.string "prenom"
    t.integer "lien_demandeur"
    t.date "date_de_naissance"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "demandeur"
    t.integer "avis_imposition_id"
    t.boolean "declarant", default: false, null: false
    t.string "civility"
    t.datetime "last_read_messages_at"
  end

  create_table "operations", id: :serial, force: :cascade do |t|
    t.string "name", default: "", null: false
    t.string "code_opal", default: "", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "payments", id: :serial, force: :cascade do |t|
    t.integer "payment_registry_id"
    t.string "statut"
    t.string "type_paiement"
    t.string "beneficiaire", default: "", null: false
    t.boolean "procuration", default: false, null: false
    t.decimal "montant", precision: 10, scale: 2
    t.datetime "submitted_at"
    t.datetime "payed_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "action"
    t.datetime "corrected_at"
    t.bigint "projet_id"
    t.index ["payment_registry_id"], name: "index_payments_on_payment_registry_id"
    t.index ["projet_id"], name: "index_payments_on_projet_id"
  end

  create_table "personnes", id: :serial, force: :cascade do |t|
    t.string "prenom"
    t.string "nom"
    t.string "tel"
    t.string "email"
    t.string "lien_avec_demandeur"
    t.string "civilite"
  end

  create_table "prestation_choices", id: :serial, force: :cascade do |t|
    t.integer "projet_id"
    t.integer "prestation_id"
    t.boolean "desired", default: false, null: false
    t.boolean "recommended", default: false, null: false
    t.boolean "selected", default: false, null: false
    t.index ["prestation_id"], name: "index_prestation_choices_on_prestation_id"
    t.index ["projet_id"], name: "index_prestation_choices_on_projet_id"
  end

  create_table "prestations", id: :serial, force: :cascade do |t|
    t.string "libelle"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "active", default: true, null: false
  end

  create_table "projet_aides", id: :serial, force: :cascade do |t|
    t.integer "projet_id"
    t.integer "aide_id"
    t.decimal "amount", precision: 10, scale: 2
    t.index ["aide_id"], name: "index_projet_aides_on_aide_id"
    t.index ["projet_id"], name: "index_projet_aides_on_projet_id"
  end

  create_table "projets", id: :serial, force: :cascade do |t|
    t.string "numero_fiscal"
    t.string "reference_avis"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "email"
    t.string "tel"
    t.string "themes", array: true
    t.integer "nb_occupants_a_charge", default: 0
    t.integer "statut", default: 0
    t.integer "operateur_id"
    t.string "opal_numero"
    t.string "opal_id"
    t.integer "personne_id"
    t.string "disponibilite"
    t.string "type_logement"
    t.string "etage"
    t.string "nb_pieces"
    t.integer "surface_habitable"
    t.string "etiquette_avant_travaux"
    t.integer "niveau_gir"
    t.boolean "handicap"
    t.boolean "demandeur_salarie"
    t.boolean "entreprise_plus_10_personnes"
    t.decimal "note_degradation", precision: 10, scale: 6
    t.decimal "note_insalubrite", precision: 10, scale: 6
    t.boolean "ventilation_adaptee"
    t.boolean "presence_humidite"
    t.boolean "auto_rehabilitation"
    t.text "remarques_diagnostic"
    t.string "etiquette_apres_travaux"
    t.integer "gain_energetique"
    t.decimal "travaux_ht_amount", precision: 10, scale: 2
    t.decimal "travaux_ttc_amount", precision: 10, scale: 2
    t.decimal "loan_amount", precision: 10, scale: 2
    t.text "precisions_travaux"
    t.text "precisions_financement"
    t.boolean "autonomie"
    t.string "plateforme_id"
    t.decimal "personal_funding_amount", precision: 10, scale: 2
    t.integer "agent_operateur_id"
    t.integer "agent_instructeur_id"
    t.integer "adresse_postale_id"
    t.integer "adresse_a_renover_id"
    t.date "date_de_visite"
    t.decimal "amo_amount", precision: 10, scale: 2
    t.decimal "maitrise_oeuvre_amount", precision: 10, scale: 2
    t.decimal "assiette_subventionnable_amount", precision: 10, scale: 2
    t.integer "consommation_avant_travaux"
    t.integer "consommation_apres_travaux"
    t.boolean "future_birth", default: false, null: false
    t.integer "user_id"
    t.integer "modified_revenu_fiscal_reference"
    t.datetime "locked_at"
    t.datetime "date_depot"
    t.integer "max_registration_step", default: 1, null: false
    t.datetime "statut_updated_date"
    t.integer "actif", default: 1
    t.string "opal_position"
    t.datetime "opal_date_position"
    t.string "opal_position_label"
    t.integer "eligibility_state"
    t.string "nature_changement_situation"
    t.string "name_op"
    t.string "code_opal_op"
    t.integer "eligibilite", default: 0, null: false
    t.string "eligibility_commentaire"
    t.index ["adresse_a_renover_id"], name: "index_projets_on_adresse_a_renover_id"
    t.index ["adresse_postale_id"], name: "index_projets_on_adresse_postale_id"
    t.index ["agent_instructeur_id"], name: "index_projets_on_agent_instructeur_id"
    t.index ["agent_operateur_id"], name: "index_projets_on_agent_operateur_id"
    t.index ["operateur_id"], name: "index_projets_on_operateur_id"
    t.index ["personne_id"], name: "index_projets_on_personne_id"
    t.index ["themes"], name: "index_projets_on_themes", using: :gin
    t.index ["user_id"], name: "index_projets_on_user_id"
  end

  create_table "projets_themes", id: false, force: :cascade do |t|
    t.integer "projet_id"
    t.integer "theme_id"
    t.index ["projet_id"], name: "index_projets_themes_on_projet_id"
    t.index ["theme_id"], name: "index_projets_themes_on_theme_id"
  end

  create_table "projets_users", force: :cascade do |t|
    t.bigint "user_id"
    t.bigint "projet_id"
    t.string "kind", default: "demandeur", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "revoked_at"
    t.index ["projet_id"], name: "index_projets_users_on_projet_id"
    t.index ["user_id"], name: "index_projets_users_on_user_id"
  end

  create_table "task_records", id: false, force: :cascade do |t|
    t.string "version", null: false
  end

  create_table "themes", id: :serial, force: :cascade do |t|
    t.string "libelle"
  end

  create_table "users", id: :serial, force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet "current_sign_in_ip"
    t.inet "last_sign_in_ip"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.index ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "agents", "intervenants"
  add_foreign_key "agents_projets", "agents"
  add_foreign_key "agents_projets", "projets"
  add_foreign_key "avis_impositions", "projets"
  add_foreign_key "demandes", "projets"
  add_foreign_key "documents", "projets"
  add_foreign_key "evenements", "projets"
  add_foreign_key "intervenants_operations", "intervenants"
  add_foreign_key "intervenants_operations", "operations"
  add_foreign_key "invitations", "intervenants"
  add_foreign_key "invitations", "projets"
  add_foreign_key "messages", "projets"
  add_foreign_key "prestation_choices", "prestations"
  add_foreign_key "prestation_choices", "projets"
  add_foreign_key "projet_aides", "aides"
  add_foreign_key "projet_aides", "projets"
  add_foreign_key "projets", "adresses", column: "adresse_a_renover_id"
  add_foreign_key "projets", "adresses", column: "adresse_postale_id"
  add_foreign_key "projets", "agents", column: "agent_instructeur_id"
  add_foreign_key "projets", "agents", column: "agent_operateur_id"
  add_foreign_key "projets", "intervenants", column: "operateur_id"
  add_foreign_key "projets", "personnes"
  add_foreign_key "projets", "users"
  add_foreign_key "projets_users", "projets"
  add_foreign_key "projets_users", "users"
end
