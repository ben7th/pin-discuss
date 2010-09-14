class Discussion < ActiveRecord::Base

  has_many :discussion_invitations
  belongs_to :workspace

  validates_presence_of :workspace_id
  
  def document
    Document.find(:repo_user_id=>self.workspace.user_id,:repo_name=>self.workspace.id,:id=>self.id.to_s)
  end

end
