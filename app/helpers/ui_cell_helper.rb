module UiCellHelper
  def hide_panel
    %~
      <style type="text/css">
        #PL-paper{margin-left:0px;}
        #PL-panel{display:none;}
      </style>
    ~
  end

  # 构建页面基本组成单元
  def content_cell(options=Hash.new(''),&block)
    # 参数处理
    title = options[:title]
    clazz = 'cell'
    clazz +=' notitle' if title==:blank
    cell_id = options[:id].blank? ? nil : options[:id]

    # 构建
    build_cell_dom({:clazz=>clazz,:title=>title,:cell_id=>cell_id},&block)

    # 清理临时变量
    clearyield :cell_head
  end

  def build_cell_dom(hash,&block)
    clazz = hash[:clazz]
    title = hash[:title]
    id = hash[:cell_id] || randstr

    layout_str = %~
    <div id='cell_#{id}' class='#{clazz}'>
      <h3 class='cell-title'>
        <span class='cell-title-text'>#{title}</span>
      </h3>
      <%unless (cell_head_str = yield :cell_head).blank? -%>
        <div class="cell-head">
          <%=cell_head_str%>
        </div>
      <%end -%>
      <div class="cell-body">
        <%=yield%>
      </div>
    </div>
    ~
    inside_inline_layout(layout_str,&block)
  end

  def cell_head(&block)
    content_for :cell_head,&block
  end

  def clearyield(name)
    eval "@content_for_#{name} = nil"
  end

  def close_box
    page << 'close_fbox();'
  end
  
# --------------- 1月23日的分割线 --------------
# --------------- 3月18日的分割线 --------------

  # 用于生成页面导航链接，导致页面布局块变化以及历史记录更新
  # 加载多个内容块时，页面内容整体变化，历史记录整体更新
  def pages_link(name,link_options={},html_options={})
    new_hash = {}
    CELLS.map { |pos|
      options = link_options[pos.to_sym]
      new_hash[pos] = url_for(options[:url]) if !options.blank?
    }
    link_to_function(name,"pie.history._load(#{new_hash.to_json},{force_load:true})",html_options)
  end

  # 生成PL框架下的页面链接 链接单个页面
  def page_link(position,name,options)
    pages_link(name,{position=>options},options[:html])
  end

  def page_link_function(position,options)
    url = url_for(options[:url])
    "pie.history._load(#{position.to_json},#{url.to_json})"
  end

end
