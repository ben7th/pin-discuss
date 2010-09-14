class DiscussionInvitationsController < ApplicationController
  before_filter :per_load
  def per_load
    @discussion_invitation = DiscussionInvitation.find_by_uuid_code(params[:id])
  end
  
  def show
    user = User.find_by_email(@discussion_invitation.email)
    @discussion_invitation.update_attributes(:viewed=>true)
    if user.blank?
      store_location_with_domain
      return render :template=>"discussion_invitations/registe"
    end
    # 如果 已经登录，并且登录的用户不是被邀请的用户
    if current_user && current_user != user
      return render :template=>"discussion_invitations/switch"
    end
    # 如果 没有 登录，或已用被邀请的用户登录
    if current_user.blank? || current_user == user
      return _login_show(user)
    end
  end

  def direct_login
    _login_show(User.find_by_email(@discussion_invitation.email))
  end

  def  _login_show(user)
    discussion = @discussion_invitation.discussion
    self.current_user = user
    workspace = discussion.workspace
    redirect_to document_path(:workspace_id=>workspace.id,:id=>discussion.id)
  end
end