class MindmapsController < ApplicationController

  skip_before_filter :verify_authenticity_token
  before_filter :check_token
  def check_token
    key = CoreService::PROJECT_CONFIG["service_key"]
    req_user_id = params[:req_user_id]
    token = params[:service_token]

    require 'digest/sha1'
    if(Digest::SHA1.hexdigest("#{req_user_id}#{key}") == token)
      @user = User.find(req_user_id)
    else
      render :text=>401,:status=>401
    end
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