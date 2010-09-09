module LoginFboxHelper
  def action_to(*args, &block)
    # 用户登录后，访问的是正常功能
    return link_to(*args, &block) if logged_in?
    # 不登录时，点击就会弹出登录对话框
    %`
      <a href="/login_fbox" rel="facebox">评论</a>
    `
  end

  #  def action_to(*args, &block)
  #    "<span class='action-link'><span>●</span><span class='link'>#{link_to(*args, &block)}</span></span>"
  #  end
end
