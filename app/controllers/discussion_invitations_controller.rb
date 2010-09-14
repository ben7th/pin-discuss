class DiscussionInvitationsController < ApplicationController
  before_filter :per_load
  def per_load
    @discussion_invitation = DiscussionInvitation.find_by_uuid_code(params[:id])
  end
  
  def show
    user = User.find_by_email(@discussion_invitation.email)
    @discussion_invitation.update_attributes(:viewed=>true)
    case true
    when !!user && (!current_user || (current_user == user)  )
      return _login_show(user)
    when !!current_user && (current_user != user)
      return render :template=>"discussion_invitations/switch"
    when !current_user && !user
      store_location_with_domain
      return render :template=>"discussion_invitations/registe"
    end
  end

  def direct_login
    user = User.find_by_email(@discussion_invitation.email)
    case true
    when !!user
      return _login_show(user)
    when !user
      store_location_with_domain
      return render :template=>"discussion_invitations/registe"
    end
  end

  def  _login_show(user)
    discussion = @discussion_invitation.discussion
    self.current_user = user
    workspace = discussion.workspace
    redirect_to document_path(:workspace_id=>workspace.id,:id=>discussion.id)
  end
end