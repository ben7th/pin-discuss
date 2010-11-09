class MindmapsController < ApplicationController

  skip_before_filter :verify_authenticity_token
  before_filter :check_token
  def check_token
#    params[:req_user_id]
#    params[:token]
    @user = User.find(params[:req_user_id])
    return true
  end

  # req_user_id workspace_id mindmap
  def create
    @workspace = Workspace.find(params[:workspace_id])
    bundle = MindmapParse.new(params[:mindmap]).parse
    document = @workspace.create_document(:email=>@user.email,:text_pin=>{:html=>bundle})
    if document
      return render :text=>"200",:status=>200
    end
    return render :text=>"500",:status=>500
  end

end