class ChangeRepositoryIdToWorkspaceId < ActiveRecord::Migration
  def self.up
    rename_column(:document_trees, :repository_id, :workspace_id)
    drop_table :repositories
  end

  def self.down
  end
end
