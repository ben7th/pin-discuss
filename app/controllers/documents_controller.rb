class DocumentsController < ApplicationController

  before_filter :login_required
  before_filter :per_load
  def per_load
    @workspace = Workspace.find(params[:workspace_id])
    @user = @workspace.user
    @document = DocumentTree.find(params[:id]).document if params[:id]
  end

  def index
    @documents = @workspace.document_trees.map do |document_tree|
      document_tree.document
    end
  end

  def new
    _new_rjs
  end

  def create
    document = @workspace.create_document(:creator=>current_user,:text_pin=>params[:text_pin])
    if document
      render_ui do |ui|
        ui.mplist :insert,{:ul=>"#mplist_documents",:model=>document},:partial=>"/documents/info_document",:locals=>{:document=>document}
        ui.fbox :close
      end
      return
    end
    _new_rjs
  end

  def _new_rjs
    render_ui do |ui|
      ui.fbox :show,:title=>"新建讨论",:partial=>"/documents/form_new"
    end
  end

  def show
  end

  def reply_form
    render_ui do |ui|
      ui.fbox :show,:title=>"回复讨论",:partial=>"/documents/form_reply"
    end
  end

  def reply
    options = {:text_pin_id=>params[:text_pin_id],:user=>current_user,:text_pin=>params[:text_pin]}
    text_pin = DocumentSyncMail.reply(@document,options)
    if text_pin
        parent = (params[:text_pin_id] ? @document.find_text_pin(params[:text_pin_id]) : nil)
        for_value = (parent.blank? ? text_pin : [parent,text_pin])
        render_ui do |ui|
          ui.mplist :insert,for_value,:partial=>"documents/parts/detail_text_pin",:locals=>{:document=>@document,:text_pin=>text_pin}
          ui.fbox(:close)
        end
    end
  end

  def raw
    render :xml=>@document.struct
  end

  # 屏蔽某个文本
  def invisible_tu
    @document.invisible_text_pin(:tid=>params[:tid],:user=>current_user)
    refresh_local_page
  end

  # 屏蔽某个人
  def invisible_uu
    @document.invisible_text_pin_editor(:tuser=>User.find(params[:tuser_id]),:user=>current_user)
    refresh_local_page
  end

  # 解封某个文本
  def visible_tu
    @document.visible_text_pin(:tid=>params[:tid],:user=>current_user)
    refresh_local_page
  end

  # 解封某人
  def visible_uu
    @document.visible_text_pin_editor(:tuser=>User.find(params[:tuser_id]),:user=>current_user)
    refresh_local_page
  end

  # 邀请某人的页面
  def invite_form
    render_ui do |ui|
      ui.fbox :show,:title=>"邀请",:partial=>"/documents/parts/invite_form"
    end
  end

  # 发起邀请
  def invite
    render_ui do |ui|
      ui.fbox :close
      if @document.invite(current_user,params[:email])
        ui.fbox :show,:title=>"消息反馈",:content=>"邀请已经发送..."
      else
        ui.fbox :show,:title=>"消息反馈",:content=>"这个人已经参与了这个话题..."
      end
    end
  end

end