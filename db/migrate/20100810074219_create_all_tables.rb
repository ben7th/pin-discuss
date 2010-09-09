class CreateAllTables < ActiveRecord::Migration
  def self.up
    create_table "discussion_invitations", :force => true do |t|
      t.integer  "inviter_id"
      t.string   "email"
      t.boolean  "viewed"
      t.string   "uuid_code"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.integer  "document_tree_id"
    end

    create_table "discussions", :force => true do |t|
      t.integer  "participant_id"
      t.boolean  "hide"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.integer  "document_tree_id"
    end

    create_table "document_trees", :force => true do |t|
      t.string   "document_id"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.integer  "repository_id"
    end

    create_table "repositories", :force => true do |t|
      t.string   "name"
      t.integer  "user_id"
      t.datetime "created_at"
      t.datetime "updated_at"
    end
  end

  def self.down
  end
end
