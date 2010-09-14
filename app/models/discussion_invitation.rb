require 'uuidtools'
class DiscussionInvitation < ActiveRecord::Base

  belongs_to :inviter,:class_name=>"User"
  belongs_to :discussion

  validates_presence_of :discussion_id
  
  validates_presence_of :inviter_id
  validates_presence_of :email

  before_create :set_uuid_code
  def set_uuid_code
    self.uuid_code = UUIDTools::UUID.random_create.to_s
  end

  def invite_status
    case true
    when joined? then "已加入"
    when responsed? then "已经响应"
    else "未响应"
    end
  end

  def responsed?
    viewed?
  end

  def joined?
    discussion.document.joined?(self.email)
  end

  def repo_name
    discussion.workspace.id
  end

  def repo_user_id
    discussion.workspace.user_id
  end

  def document_id
    discussion_id
  end
end