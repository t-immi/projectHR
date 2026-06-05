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

ActiveRecord::Schema[8.1].define(version: 2025_06_05_130002) do
  create_table "match_scores", force: :cascade do |t|
    t.string "computed_by", default: "ml_model", null: false
    t.datetime "created_at", null: false
    t.bigint "resume_id", null: false
    t.decimal "score", precision: 5, scale: 4, null: false
    t.datetime "updated_at", null: false
    t.bigint "vacancy_id", null: false
    t.index ["resume_id", "vacancy_id"], name: "index_match_scores_on_resume_id_and_vacancy_id", unique: true
    t.index ["resume_id"], name: "index_match_scores_on_resume_id"
    t.index ["score"], name: "index_match_scores_on_score"
    t.index ["vacancy_id"], name: "index_match_scores_on_vacancy_id"
  end

  create_table "resumes", force: :cascade do |t|
    t.text "body", null: false
    t.datetime "created_at", null: false
    t.string "hh_external_id"
    t.string "source", default: "upload", null: false
    t.string "title", null: false
    t.datetime "updated_at", null: false
    t.integer "user_id"
    t.index ["hh_external_id"], name: "index_resumes_on_hh_external_id", unique: true, where: "(hh_external_id IS NOT NULL)"
    t.index ["source"], name: "index_resumes_on_source"
    t.index ["user_id"], name: "index_resumes_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.text "access_token"
    t.datetime "created_at", null: false
    t.string "email"
    t.datetime "expires_at"
    t.string "hh_id", null: false
    t.string "name"
    t.text "refresh_token"
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email"
    t.index ["hh_id"], name: "index_users_on_hh_id", unique: true
  end

  create_table "vacancies", force: :cascade do |t|
    t.text "body", null: false
    t.datetime "created_at", null: false
    t.string "hh_external_id"
    t.string "source", default: "upload", null: false
    t.string "title", null: false
    t.datetime "updated_at", null: false
    t.integer "user_id"
    t.index ["hh_external_id"], name: "index_vacancies_on_hh_external_id", unique: true, where: "hh_external_id IS NOT NULL"
    t.index ["source"], name: "index_vacancies_on_source"
    t.index ["user_id"], name: "index_vacancies_on_user_id"
  end

  add_foreign_key "match_scores", "resumes"
  add_foreign_key "match_scores", "vacancies"
  add_foreign_key "resumes", "users"
  add_foreign_key "vacancies", "users"
end
