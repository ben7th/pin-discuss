class TextPinsController < ApplicationController

  before_filter :per_load
  def per_load
    if params[:document_id]
      @document = DocumentTree.find_by_workspace_id_and_id(params[:workspace_id],params[:document_id]).document
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
    if @document.edit_text_pin(:text_pin_id=>params[:id],:text_pin=>params[:text_pin],:user=>current_user)
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
    if @document.remove_text_pin({:text_pin_id=>params[:id],:user=>current_user})
      render_ui.mplist :remove,@text_pin
    end
  end

  def raw
    render :xml=>@text_pin.struct
  end

end