class RemoveDocumentIdFromDocumentTrees < ActiveRecord::Migration
  def self.up
    remove_column :document_trees,:document_id
  end

  def self.down
  end
end
