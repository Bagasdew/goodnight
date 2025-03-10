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

ActiveRecord::Schema[7.1].define(version: 2025_02_11_131423) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "follow_lists", force: :cascade do |t|
    t.bigint "follower_id", null: false
    t.bigint "followee_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["followee_id"], name: "index_follow_lists_on_followee_id"
    t.index ["follower_id"], name: "index_follow_lists_on_follower_id"
  end

  create_table "presences", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.datetime "clock_in", null: false
    t.datetime "clock_out"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["clock_in", "clock_out"], name: "index_presences_on_clock_in_and_clock_out"
    t.index ["user_id"], name: "index_presences_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_users_on_name", unique: true
  end

  add_foreign_key "follow_lists", "users", column: "followee_id"
  add_foreign_key "follow_lists", "users", column: "follower_id"
  add_foreign_key "presences", "users"
end
