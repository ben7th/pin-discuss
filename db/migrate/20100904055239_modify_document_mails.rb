class ModifyDocumentMails < ActiveRecord::Migration
  def self.up
    drop_table :document_mails
    create_table :document_messages do |t|
      t.string :mmid
      t.integer :document_tree_id
      t.timestamps
    end
  end

  def self.down
  end
end
