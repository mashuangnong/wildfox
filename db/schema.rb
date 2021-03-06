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

ActiveRecord::Schema.define(version: 20161212014512) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "components", force: :cascade do |t|
    t.jsonb "components"
  end

  create_table "control_data", force: :cascade do |t|
    t.integer "data_nodes_id"
    t.integer "data"
  end

  add_index "control_data", ["data_nodes_id"], name: "index_control_data_on_data_nodes_id", using: :btree

  create_table "data_nodes", force: :cascade do |t|
    t.integer "data_sources_id"
    t.string  "name"
    t.json    "describe"
  end

  add_index "data_nodes", ["data_sources_id"], name: "index_data_nodes_on_data_sources_id", using: :btree

  create_table "data_sources", force: :cascade do |t|
    t.string "name"
    t.string "genre"
    t.string "state"
    t.json   "describe"
  end

  create_table "devices", force: :cascade do |t|
    t.jsonb "devices"
  end

  create_table "history_data", force: :cascade do |t|
    t.string  "describe"
    t.integer "data"
    t.string  "create_time"
  end

  create_table "runtimes", force: :cascade do |t|
    t.string "describe"
    t.jsonb  "runtimes"
  end

  create_table "state_data", force: :cascade do |t|
    t.integer "data_nodes_id"
    t.integer "data"
  end

  add_index "state_data", ["data_nodes_id"], name: "index_state_data_on_data_nodes_id", using: :btree

end
