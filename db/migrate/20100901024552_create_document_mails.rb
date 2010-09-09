class CreateDocumentMails < ActiveRecord::Migration
  def self.up
    create_table :document_mails do |t|
      t.string :mail_message_id
      t.integer :document_tree_id
      t.timestamps
    end
  end

  def self.down
    drop_table :document_mails
  end
end
