class RepositoryDiff
  
  attr_reader :last_name,:new_name, :kind, :diff, :mime_type,:last_commit_id,:new_commit_id
  
  def initialize(options)
    @attrs = options
    @attrs.each do |name,value|
      self.instance_variable_set("@#{name}", value)
    end
  end 
    
  def self.build_from_diff(diff,commit)
    last_name, new_name = diff.a_path, diff.b_path
    
    kind = case true
    when diff.new_file then "ADD"
    when diff.deleted_file then 'DELETE'
    else 'MODIFY'
    end
    
    mime_type = (diff.a_blob || diff.b_blob).mime_type
    
    self_commit_id = commit.id
    parent_commit = commit.parents[0]
    parent_commit_id = parent_commit ? parent_commit.id : nil
    diff = diff.diff
    RepositoryDiff.new(:last_name=>last_name,:new_name=>new_name,:kind=>kind,
      :mime_type=>mime_type,:new_commit_id=>self_commit_id,:diff=>diff,
      :last_commit_id=>parent_commit_id)
  end
  
end