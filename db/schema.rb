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

ActiveRecord::Schema.define(version: 2021_04_21_212041) do

  create_table "expenses", force: :cascade do |t|
    t.string "name"
    t.string "description"
    t.string "date"
    t.string "user_guid"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.float "amount"
  end

  create_table "incomes", force: :cascade do |t|
    t.string "name"
    t.string "date"
    t.float "amount"
    t.string "user_guid"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "members", force: :cascade do |t|
    t.string "guid"
    t.string "member_id"
    t.string "user_guid"
    t.string "aggregated_at"
    t.string "institution_code"
    t.string "is_being_aggregated"
    t.boolean "is_oauth"
    t.string "metadata"
    t.string "name"
    t.string "successfully_aggregated_at"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "users", force: :cascade do |t|
    t.string "guid"
    t.string "user_id"
    t.string "email"
    t.boolean "is_disabled"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "password_digest"
    t.string "metadata"
    t.index ["user_id"], name: "index_users_on_user_id", unique: true
  end

end
