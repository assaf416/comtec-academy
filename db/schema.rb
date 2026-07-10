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

ActiveRecord::Schema[8.1].define(version: 2026_07_10_082418) do
  create_table "active_storage_attachments", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.bigint "record_id", null: false
    t.string "record_type", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.string "content_type"
    t.datetime "created_at", null: false
    t.string "filename", null: false
    t.string "key", null: false
    t.text "metadata"
    t.string "service_name", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "activities", force: :cascade do |t|
    t.string "action"
    t.datetime "created_at", null: false
    t.text "metadata"
    t.integer "subject_id"
    t.string "subject_type"
    t.datetime "updated_at", null: false
    t.integer "user_id", null: false
    t.index ["user_id"], name: "index_activities_on_user_id"
  end

  create_table "brand_themes", force: :cascade do |t|
    t.string "accent_color"
    t.string "background_color"
    t.string "body_font"
    t.datetime "created_at", null: false
    t.string "heading_font"
    t.string "primary_color"
    t.string "text_color"
    t.datetime "updated_at", null: false
  end

  create_table "chat_messages", force: :cascade do |t|
    t.text "body", null: false
    t.datetime "created_at", null: false
    t.integer "episode_id", null: false
    t.integer "role", default: 0, null: false
    t.datetime "updated_at", null: false
    t.integer "user_id", null: false
    t.index ["episode_id"], name: "index_chat_messages_on_episode_id"
    t.index ["user_id"], name: "index_chat_messages_on_user_id"
  end

  create_table "courses", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "details"
    t.string "name", null: false
    t.boolean "published", default: false, null: false
    t.datetime "updated_at", null: false
  end

  create_table "documents", force: :cascade do |t|
    t.text "content"
    t.datetime "created_at", null: false
    t.integer "doc_type", null: false
    t.integer "project_id"
    t.integer "source", default: 0, null: false
    t.string "tags"
    t.string "title"
    t.datetime "updated_at", null: false
    t.integer "views_count", default: 0, null: false
    t.index ["project_id", "doc_type"], name: "index_documents_on_project_id_and_doc_type", unique: true
    t.index ["project_id"], name: "index_documents_on_project_id"
  end

  create_table "episodes", force: :cascade do |t|
    t.string "audiobook_url"
    t.integer "course_id", null: false
    t.datetime "created_at", null: false
    t.integer "kind", default: 0, null: false
    t.string "movie_url"
    t.string "name"
    t.integer "position", default: 0, null: false
    t.string "title"
    t.text "transcript"
    t.datetime "updated_at", null: false
    t.index ["course_id"], name: "index_episodes_on_course_id"
  end

  create_table "favorites", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "document_id", null: false
    t.datetime "updated_at", null: false
    t.integer "user_id", null: false
    t.index ["document_id"], name: "index_favorites_on_document_id"
    t.index ["user_id", "document_id"], name: "index_favorites_on_user_id_and_document_id", unique: true
    t.index ["user_id"], name: "index_favorites_on_user_id"
  end

  create_table "markdown_docs", force: :cascade do |t|
    t.text "content"
    t.datetime "created_at", null: false
    t.integer "episode_id", null: false
    t.string "name"
    t.datetime "updated_at", null: false
    t.index ["episode_id"], name: "index_markdown_docs_on_episode_id"
  end

  create_table "project_memberships", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "project_id", null: false
    t.datetime "updated_at", null: false
    t.integer "user_id", null: false
    t.index ["project_id"], name: "index_project_memberships_on_project_id"
    t.index ["user_id", "project_id"], name: "index_project_memberships_on_user_id_and_project_id", unique: true
    t.index ["user_id"], name: "index_project_memberships_on_user_id"
  end

  create_table "projects", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "description"
    t.string "name"
    t.string "slug"
    t.datetime "updated_at", null: false
    t.index ["slug"], name: "index_projects_on_slug", unique: true
  end

  create_table "quiz_answers", force: :cascade do |t|
    t.text "answer"
    t.datetime "created_at", null: false
    t.integer "quiz_question_id", null: false
    t.datetime "updated_at", null: false
    t.integer "user_id", null: false
    t.index ["quiz_question_id"], name: "index_quiz_answers_on_quiz_question_id"
    t.index ["user_id"], name: "index_quiz_answers_on_user_id"
  end

  create_table "quiz_questions", force: :cascade do |t|
    t.text "choices"
    t.string "correct_choice"
    t.datetime "created_at", null: false
    t.integer "episode_id", null: false
    t.text "prompt"
    t.datetime "updated_at", null: false
    t.index ["episode_id"], name: "index_quiz_questions_on_episode_id"
  end

  create_table "sessions", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "ip_address"
    t.datetime "updated_at", null: false
    t.string "user_agent"
    t.integer "user_id", null: false
    t.index ["user_id"], name: "index_sessions_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.datetime "activated_at"
    t.string "avatar_url"
    t.datetime "created_at", null: false
    t.string "email_address", null: false
    t.datetime "invited_at"
    t.string "name"
    t.string "password_digest"
    t.string "phone"
    t.integer "role", default: 0, null: false
    t.integer "status", default: 0, null: false
    t.datetime "updated_at", null: false
    t.index ["email_address"], name: "index_users_on_email_address", unique: true
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "activities", "users"
  add_foreign_key "chat_messages", "episodes"
  add_foreign_key "chat_messages", "users"
  add_foreign_key "documents", "projects"
  add_foreign_key "episodes", "courses"
  add_foreign_key "favorites", "documents"
  add_foreign_key "favorites", "users"
  add_foreign_key "markdown_docs", "episodes"
  add_foreign_key "project_memberships", "projects"
  add_foreign_key "project_memberships", "users"
  add_foreign_key "quiz_answers", "quiz_questions"
  add_foreign_key "quiz_answers", "users"
  add_foreign_key "quiz_questions", "episodes"
  add_foreign_key "sessions", "users"
end
