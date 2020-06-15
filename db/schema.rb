# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `rails
# db:schema:load`. When creating a new database, `rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2020_06_15_042456) do

  create_table "delayed_jobs", force: :cascade do |t|
    t.integer "priority", default: 0, null: false
    t.integer "attempts", default: 0, null: false
    t.text "handler", null: false
    t.text "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string "locked_by"
    t.string "queue"
    t.datetime "created_at", precision: 6
    t.datetime "updated_at", precision: 6
    t.index ["priority", "run_at"], name: "delayed_jobs_priority"
  end

  create_table "user_follower_imports", force: :cascade do |t|
    t.integer "num_all_followers"
    t.integer "num_synced"
    t.string "next_cursor"
    t.boolean "completed"
    t.integer "user_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["user_id"], name: "index_user_follower_imports_on_user_id"
  end

  create_table "user_followers", force: :cascade do |t|
    t.string "uid"
    t.string "name"
    t.string "screen_name"
    t.string "image_url"
    t.boolean "protected"
    t.boolean "verified"
    t.integer "followers_count"
    t.string "account_created_at"
    t.string "location"
    t.integer "score"
    t.integer "score_version"
    t.integer "user_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["user_id"], name: "index_user_followers_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "uid"
    t.string "user_name"
    t.string "image_url"
    t.string "nickname"
    t.string "oauth_token"
    t.string "oauth_secret"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

end
