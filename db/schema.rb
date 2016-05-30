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

ActiveRecord::Schema.define(version: 20160530200741) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

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

  create_table "projets", force: :cascade do |t|
    t.string   "numero_fiscal"
    t.string   "reference_avis"
    t.text     "description"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "usager"
    t.string   "adresse"
  end

end
