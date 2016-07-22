# encoding: UTF-8
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

ActiveRecord::Schema.define(version: 20160722152401) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "avis_impositions", force: :cascade do |t|
    t.string   "numero_fiscal"
    t.string   "reference_avis"
    t.integer  "annee"
    t.integer  "revenu_fiscal_reference"
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
    t.integer  "projet_id"
    t.string   "declarant_1"
    t.string   "declarant_2"
    t.integer  "nombre_personnes_charge"
  end

  add_index "avis_impositions", ["projet_id"], name: "index_avis_impositions_on_projet_id", using: :btree

  create_table "commentaires", force: :cascade do |t|
    t.integer  "projet_id"
    t.integer  "auteur_id"
    t.string   "auteur_type"
    t.text     "corps_message"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
  end

  add_index "commentaires", ["auteur_type", "auteur_id"], name: "index_commentaires_on_auteur_type_and_auteur_id", using: :btree
  add_index "commentaires", ["projet_id"], name: "index_commentaires_on_projet_id", using: :btree

  create_table "contacts", force: :cascade do |t|
    t.string   "nom"
    t.string   "role"
    t.string   "email"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "contacts_projets", id: false, force: :cascade do |t|
    t.integer "projet_id"
    t.integer "contact_id"
  end

  add_index "contacts_projets", ["contact_id"], name: "index_contacts_projets_on_contact_id", using: :btree
  add_index "contacts_projets", ["projet_id"], name: "index_contacts_projets_on_projet_id", using: :btree

  create_table "evenements", force: :cascade do |t|
    t.integer  "projet_id"
    t.string   "label"
    t.datetime "quand"
    t.integer  "producteur_id"
    t.string   "producteur_type"
  end

  add_index "evenements", ["producteur_type", "producteur_id"], name: "index_evenements_on_producteur_type_and_producteur_id", using: :btree
  add_index "evenements", ["projet_id"], name: "index_evenements_on_projet_id", using: :btree

  create_table "intervenants", force: :cascade do |t|
    t.string "raison_sociale"
    t.string "adresse_postale"
    t.string "themes",          array: true
    t.string "departements",    array: true
    t.string "email"
    t.string "roles",           array: true
    t.text   "informations"
  end

  add_index "intervenants", ["departements"], name: "index_intervenants_on_departements", using: :gin
  add_index "intervenants", ["roles"], name: "index_intervenants_on_roles", using: :gin
  add_index "intervenants", ["themes"], name: "index_intervenants_on_themes", using: :gin

  create_table "invitations", force: :cascade do |t|
    t.integer "projet_id"
    t.integer "intervenant_id"
    t.string  "token"
    t.integer "intermediaire_id"
  end

  add_index "invitations", ["intermediaire_id"], name: "index_invitations_on_intermediaire_id", using: :btree
  add_index "invitations", ["intervenant_id"], name: "index_invitations_on_intervenant_id", using: :btree
  add_index "invitations", ["projet_id"], name: "index_invitations_on_projet_id", using: :btree
  add_index "invitations", ["token"], name: "index_invitations_on_token", using: :btree

  create_table "occupants", force: :cascade do |t|
    t.integer  "projet_id"
    t.string   "nom"
    t.string   "prenom"
    t.string   "lien_demandeur"
    t.date     "date_de_naissance"
    t.integer  "civilite"
    t.datetime "created_at",        null: false
    t.datetime "updated_at",        null: false
    t.boolean  "demandeur"
  end

  add_index "occupants", ["projet_id"], name: "index_occupants_on_projet_id", using: :btree

  create_table "prestations", force: :cascade do |t|
    t.string   "libelle"
    t.string   "entreprise"
    t.float    "montant"
    t.boolean  "recevable"
    t.integer  "projet_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string   "scenario"
  end

  add_index "prestations", ["projet_id"], name: "index_prestations_on_projet_id", using: :btree

  create_table "projets", force: :cascade do |t|
    t.string   "numero_fiscal"
    t.string   "reference_avis"
    t.text     "description"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "adresse"
    t.float    "latitude"
    t.float    "longitude"
    t.string   "departement"
    t.string   "email"
    t.string   "tel"
    t.string   "themes",                            array: true
    t.integer  "nb_occupants_a_charge", default: 0
  end

  add_index "projets", ["themes"], name: "index_projets_on_themes", using: :gin

  add_foreign_key "avis_impositions", "projets"
  add_foreign_key "commentaires", "projets"
  add_foreign_key "evenements", "projets"
  add_foreign_key "invitations", "intervenants"
  add_foreign_key "invitations", "projets"
  add_foreign_key "occupants", "projets"
  add_foreign_key "prestations", "projets"
end
