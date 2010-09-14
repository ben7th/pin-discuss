require "mail"
require "uuidtools"
class DocumentSyncMail

  # mmid
  def self.mmid
    "<#{UUIDTools::UUID.random_create.to_s}@mindpin_discussion.mail>"
  end

  # 创建document，document_message并发送邮件
  def self.create(options)
    options[:mmid] ||= self.mmid
    document = Document.create(options)
    if document
      self.send_mail_to_members(document.discussion.workspace,
        {:mmid=>options[:mmid],:body=>options[:text_pin][:html],:subject=>"新话题公告"})
      return document
    end
    return false
  end

  def self.reply(document,options)
    options[:mmid] ||= self.mmid
    rmmid = options[:text_pin_id]
    return_value = document.reply(options)
    if return_value
      self.send_mail_to_members(document.discussion.workspace,
        {:mmid=>options[:mmid],:body=>options[:text_pin][:html],:subject=>"回复话题公告",:rmmid=>rmmid})
      return return_value
    end
    return false
  end

  # 如果 收件人是这个工作空间的
  # 根据邮件的 message_id 和 in_reply_to 处理这个邮件
  # 创建新讨论话题，或者回复一个话题
  def self.receive(email_hash)
    workspace = Workspace.find(email_hash[:to].sub("workspaces_",""))
    return create_discuss(workspace,email_hash) if email_hash[:in_reply_to].blank?
    reply_discuss(email_hash)
  end

  def self.reply_discuss(email_hash)
    discussion_message = DiscussionMessage.find_by_mmid(email_hash[:in_reply_to])
    document = discussion_message.discussion.document
    options = {
      :mmid=>email_hash[:message_id],
      :text_pin_id=>discussion_message.text_pin_id,
      :email=>email_hash[:from],
      :text_pin=>{:html=>email_hash[:body]}
    }
    DocumentSyncMail.reply(document,options)
  end

  def self.create_discuss(workspace,email_hash)
    email = email_hash[:from]
    options = {:mmid=>email_hash[:message_id],:email=>email,:text_pin=>{:html=>email_hash[:body]}}
    workspace.create_document(options)
  end

  # 发送邮件需要三个参数
  # workspace的成员，mmid，邮件内容
  # 把新话题的内容发送给 工作空间的所有成员和空间的创建者
  def self.send_mail_to_members(workspace,email_hash)
    emails = workspace.member_emails
    emails << workspace.user.email
    emails.each do |email|
      mail = Mail.new do
        from workspace.mail_address
        to email
        subject email_hash[:subject]
        body email_hash[:body]
        message_id email_hash[:mmid]
        in_reply_to email_hash[:rmmid] if !email_hash[:rmmid].blank?
      end
      mail.deliver
    end
  end


end
