class ModifyDocumentMessages < ActiveRecord::Migration
  def self.up
    add_column :document_messages, :text_pin_id, :string
  end

  def self.down
    remove_column :document_messages, :text_pin_id
  end
end
