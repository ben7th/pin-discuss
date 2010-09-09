class EmailDiscuss

  attr_accessor :email

  def initialize(email)
    @email = email
    @workspace = Workspace.find(@email[:to].sub("workspaces_",""))
    @workspace_email = "workspaces_#{@workspace.id}@ben7th.com"
  end

  def self.process_email(email)
    self.new(email).process_mail_content
  end

  def process_mail_content
    from = @email[:from]
    if @workspace.member_emails.include?(from) || (@workspace.user.email == from)
      return create_or_replay_discuss
    end
    send_refuse_email
  end

  def create_or_replay_discuss
    DocumentSyncMail.receive(@email)
  end

  # 如果 发信人不是这个工作空间的
  # 拒绝 接受 它的邮件
  # 并给 发信人 发送一封拒收邮件
  def send_refuse_email
    Mailer.deliver_workspace_refuse_email(@workspace,@email[:from])
  end
end
