# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.0].define(version: 2022_03_20_161358) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  # Custom types defined in this database.
  # Note that some types may not work with other database engines. Be careful if changing database.
  create_enum "account_roles", ["admin", "manager", "finance", "worker"]
  create_enum "auth_identity_providers", ["keepa"]

  create_table "accounts", force: :cascade do |t|
    t.string "full_name", null: false
    t.string "public_id", null: false
    t.string "email", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.enum "role", null: false, enum_type: "account_roles"
    t.index ["email"], name: "index_accounts_on_email", unique: true
  end

  create_table "auth_identities", force: :cascade do |t|
    t.string "uid", null: false
    t.string "token", null: false
    t.string "login", null: false
    t.string "provider", null: false
    t.bigint "account_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["account_id"], name: "index_auth_identities_on_account_id"
  end

  add_foreign_key "auth_identities", "accounts"
end
