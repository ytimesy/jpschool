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

ActiveRecord::Schema[8.1].define(version: 2026_09_01_000100) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "courses", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.boolean "published", default: false, null: false
    t.string "slug", null: false
    t.integer "sort_order", default: 0, null: false
    t.jsonb "title_i18n", default: {}, null: false
    t.datetime "updated_at", null: false
    t.index ["slug"], name: "index_courses_on_slug", unique: true
  end

  create_table "dialogue_lines", force: :cascade do |t|
    t.string "audio_path"
    t.string "content_key", null: false
    t.datetime "created_at", null: false
    t.bigint "dialogue_id", null: false
    t.text "japanese_text", null: false
    t.text "kana_text", null: false
    t.integer "sort_order", default: 0, null: false
    t.string "speaker", null: false
    t.jsonb "translation_i18n", default: {}, null: false
    t.datetime "updated_at", null: false
    t.index ["dialogue_id", "content_key"], name: "index_dialogue_lines_on_dialogue_id_and_content_key", unique: true
    t.index ["dialogue_id"], name: "index_dialogue_lines_on_dialogue_id"
  end

  create_table "dialogues", force: :cascade do |t|
    t.string "content_key", null: false
    t.datetime "created_at", null: false
    t.bigint "lesson_id", null: false
    t.integer "sort_order", default: 0, null: false
    t.jsonb "title_i18n", default: {}, null: false
    t.datetime "updated_at", null: false
    t.index ["lesson_id", "content_key"], name: "index_dialogues_on_lesson_id_and_content_key", unique: true
    t.index ["lesson_id"], name: "index_dialogues_on_lesson_id"
  end

  create_table "lessons", force: :cascade do |t|
    t.integer "content_version", default: 1, null: false
    t.bigint "course_id", null: false
    t.datetime "created_at", null: false
    t.integer "estimated_minutes", null: false
    t.jsonb "objective_i18n", default: {}, null: false
    t.datetime "published_at"
    t.datetime "reviewed_at"
    t.string "slug", null: false
    t.integer "sort_order", default: 0, null: false
    t.jsonb "title_i18n", default: {}, null: false
    t.datetime "updated_at", null: false
    t.string "validation_status", default: "draft", null: false
    t.index ["course_id"], name: "index_lessons_on_course_id"
    t.index ["slug"], name: "index_lessons_on_slug", unique: true
    t.check_constraint "validation_status::text = ANY (ARRAY['draft'::character varying, 'valid'::character varying, 'invalid'::character varying]::text[])", name: "lessons_validation_status_check"
  end

  create_table "phrases", force: :cascade do |t|
    t.string "audio_path"
    t.string "content_key", null: false
    t.datetime "created_at", null: false
    t.text "japanese_text", null: false
    t.text "kana_text", null: false
    t.bigint "lesson_id", null: false
    t.jsonb "note_i18n", default: {}, null: false
    t.integer "sort_order", default: 0, null: false
    t.jsonb "translation_i18n", default: {}, null: false
    t.datetime "updated_at", null: false
    t.index ["lesson_id", "content_key"], name: "index_phrases_on_lesson_id_and_content_key", unique: true
    t.index ["lesson_id"], name: "index_phrases_on_lesson_id"
  end

  create_table "quiz_options", force: :cascade do |t|
    t.string "content_key", null: false
    t.boolean "correct", default: false, null: false
    t.datetime "created_at", null: false
    t.bigint "quiz_id", null: false
    t.integer "sort_order", default: 0, null: false
    t.jsonb "text_i18n", default: {}, null: false
    t.text "text_ja", null: false
    t.datetime "updated_at", null: false
    t.index ["quiz_id", "content_key"], name: "index_quiz_options_on_quiz_id_and_content_key", unique: true
    t.index ["quiz_id"], name: "index_quiz_options_on_quiz_id"
  end

  create_table "quizzes", force: :cascade do |t|
    t.string "audio_path"
    t.string "content_key", null: false
    t.datetime "created_at", null: false
    t.jsonb "explanation_i18n", default: {}, null: false
    t.string "kind", null: false
    t.bigint "lesson_id", null: false
    t.string "option_locale", null: false
    t.jsonb "question_i18n", default: {}, null: false
    t.text "question_ja", null: false
    t.text "question_kana"
    t.boolean "reuse_allowed", default: false, null: false
    t.text "reuse_reason"
    t.integer "sort_order", default: 0, null: false
    t.bigint "source_dialogue_line_id"
    t.bigint "source_phrase_id"
    t.datetime "updated_at", null: false
    t.index ["lesson_id", "content_key"], name: "index_quizzes_on_lesson_id_and_content_key", unique: true
    t.index ["lesson_id"], name: "index_quizzes_on_lesson_id"
    t.index ["source_dialogue_line_id"], name: "index_quizzes_on_source_dialogue_line_id"
    t.index ["source_phrase_id"], name: "index_quizzes_on_source_phrase_id"
    t.check_constraint "(source_phrase_id IS NULL) <> (source_dialogue_line_id IS NULL)", name: "quizzes_one_source_check"
    t.check_constraint "option_locale::text = ANY (ARRAY['learner'::character varying, 'ja'::character varying]::text[])", name: "quizzes_option_locale_check"
  end

  add_foreign_key "dialogue_lines", "dialogues"
  add_foreign_key "dialogues", "lessons"
  add_foreign_key "lessons", "courses"
  add_foreign_key "phrases", "lessons"
  add_foreign_key "quiz_options", "quizzes"
  add_foreign_key "quizzes", "dialogue_lines", column: "source_dialogue_line_id"
  add_foreign_key "quizzes", "lessons"
  add_foreign_key "quizzes", "phrases", column: "source_phrase_id"
end
