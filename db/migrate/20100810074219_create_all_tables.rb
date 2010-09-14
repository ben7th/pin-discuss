class CreateAllTables < ActiveRecord::Migration
  def self.up
    create_table "discussion_invitations", :force => true do |t|
      t.integer  "inviter_id"
      t.string   "email"
      t.boolean  "viewed"
      t.string   "uuid_code"
      t.integer  "discussion_id"
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    create_table "discussion_messages", :force => true do |t|
      t.string "mmid"
      t.integer  "discussion_id"
      t.string "text_pin_id"
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    create_table "discussion_participants", :force => true do |t|
      t.string  "email"
      t.integer  "discussion_id"
      t.boolean  "hide"
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    create_table "discussions", :force => true do |t|
      t.integer "workspace_id"
      t.datetime "created_at"
      t.datetime "updated_at"
    end
  end

  def self.down
    drop_table "discussion_invitations"
    drop_table "discussion_messages"
    drop_table "discussion_participants"
    drop_table "discussions"
  end
end
