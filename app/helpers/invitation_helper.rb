module InvitationHelper

  def invitation_stated(invitation)
    if invitation.registered?
      return "已注册"
    end
    return "未注册"
  end
  
end