class Mailer < ActionMailer::Base
  helper :datetime
  
  # 邀请某人参加话题
  def invite_to_document(discussion_invitation,document)
    email = discussion_invitation.email
    @recipients = email
    @from = 'MindPin<noreply@mindpin.com>'
    @body = {'discussion_invitation' => discussion_invitation,"document"=>document}
    @subject = "邀请讨论"
    @sent_on = Time.now
    @content_type = "text/html"
  end

  # workspace拒绝那些不在自己成员列表中的邮件的用户
  def workspace_refuse_email(workspace,email)
    @recipients = email
    @from = 'MindPin<noreply@mindpin.com>'
    @body = {'workspace' => workspace}
    @subject = "拒绝邮件"
    @sent_on = Time.now
    @content_type = "text/html"
  end

end