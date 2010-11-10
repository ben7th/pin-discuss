class TextPinsController < ApplicationController

  before_filter :per_load
  def per_load
    if params[:document_id]
      @document = Discussion.find_by_workspace_id_and_id(params[:workspace_id],params[:document_id]).document
    end
    @text_pin = @document.find_text_pin(params[:id]) if params[:id]
  end

  def show
  end

  def edit
    render_ui do |ui|
      ui.fbox :show,:title=>"修改",:partial=>"/text_pins/form_edit",:locals=>{:text_pin=>@text_pin}
    end
  end

  def update
    if @document.edit_text_pin(:text_pin_id=>params[:id],:text_pin=>params[:text_pin],:email=>current_user.email)
      render_ui do |ui|
        text_pin = @document.find_text_pin(params[:id])
        ui.mplist :update,text_pin,:partial=>"documents/parts/detail_text_pin",:locals=>{:document=>@document,:text_pin=>text_pin}
        ui.fbox(:close)
      end
      return
    end
    render :action=>:edit
  end

  def destroy
    if @document.remove_text_pin({:text_pin_id=>params[:id],:email=>current_user.email})
      render_ui.mplist :remove,@text_pin
    end
  end

  def raw
    render :xml=>@text_pin.struct
  end

  def convert_mindmap
    require 'digest/sha1'
    key = CoreService::PROJECT_CONFIG["service_key"]
    service_token = Digest::SHA1.hexdigest("#{current_user.id}#{key}")

    res = Net::HTTP.post_form URI.parse(pin_url_for('pin-mindmap-editor','/mindmaps/bundles')),
      :bundle=>@text_pin.plain_content,:req_user_id=>current_user.id,:service_token=>service_token

    case res
    when Net::HTTPSuccess, Net::HTTPRedirection
      url = pin_url_for('pin-app-adapter','app/mindmap_editor')
      render_ui.fbox :show,:content=>"操作成功，<a target='_blank' href='#{url}'>查看详情<a>"
    else
      render_ui.fbox :show,:content=>"操作失败"
    end

  end

end