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

ActiveRecord::Schema[7.0].define(version: 2023_08_08_212809) do
  create_table "artwork_to_artists", force: :cascade do |t|
    t.integer "artist_id"
    t.integer "piece_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["artist_id"], name: "index_artwork_to_artists_on_artist_id"
    t.index ["piece_id"], name: "index_artwork_to_artists_on_piece_id"
  end

  create_table "locations", force: :cascade do |t|
    t.string "short_name", null: false
    t.string "display_name", null: false
    t.string "url"
    t.string "city"
    t.string "state"
    t.string "country"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "instagram"
    t.string "facebook"
  end

  create_table "subjects", force: :cascade do |t|
    t.string "short_name", null: false
    t.string "display_name", null: false
    t.string "url"
    t.string "instagram"
    t.string "facebook"
    t.string "bandcamp"
    t.string "subject_type"
    t.string "pronouns"
    t.string "info"
    t.string "patreon"
    t.integer "artist_id"
    t.string "long_name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "soundcloud"
    t.index ["artist_id"], name: "index_subjects_on_artist_id"
    t.index ["short_name"], name: "index_subjects_on_short_name", unique: true
  end

  add_foreign_key "artwork_to_artists", "subjects", column: "artist_id"
  add_foreign_key "artwork_to_artists", "subjects", column: "piece_id"
  add_foreign_key "subjects", "subjects", column: "artist_id"
end
