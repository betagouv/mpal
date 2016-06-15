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

ActiveRecord::Schema.define(version: 20160615131638) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "agents", force: :cascade do |t|
    t.string   "username",                       null: false
    t.integer  "sign_in_count",      default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet     "current_sign_in_ip"
    t.inet     "last_sign_in_ip"
    t.datetime "created_at",                     null: false
    t.datetime "updated_at",                     null: false
  end

  add_index "agents", ["username"], name: "index_agents_on_username", unique: true, using: :btree

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

  create_table "invitations", id: false, force: :cascade do |t|
    t.integer "projet_id"
    t.integer "operateur_id"
    t.string  "token"
  end

  add_index "invitations", ["operateur_id"], name: "index_invitations_on_operateur_id", using: :btree
  add_index "invitations", ["projet_id"], name: "index_invitations_on_projet_id", using: :btree
  add_index "invitations", ["token"], name: "index_invitations_on_token", using: :btree

  create_table "operateurs", force: :cascade do |t|
    t.string "raison_sociale"
    t.string "adresse_postale"
    t.string "type"
    t.string "themes",          array: true
    t.string "departements",    array: true
    t.string "email"
  end

  add_index "operateurs", ["departements"], name: "index_operateurs_on_departements", using: :gin
  add_index "operateurs", ["themes"], name: "index_operateurs_on_themes", using: :gin

  create_table "projets", force: :cascade do |t|
    t.string   "numero_fiscal"
    t.string   "reference_avis"
    t.text     "description"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "usager"
    t.string   "adresse"
    t.float    "latitude"
    t.float    "longitude"
    t.string   "departement"
    t.string   "email"
    t.string   "tel"
    t.string   "themes",         array: true
  end

  add_index "projets", ["themes"], name: "index_projets_on_themes", using: :gin

  add_foreign_key "invitations", "operateurs"
  add_foreign_key "invitations", "projets"
end
