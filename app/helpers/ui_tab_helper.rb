module UiTabHelper
  def tab_panel(*args,&block)
    options = args.extract_options!
    id = options[:id]
    block.call()

    ul = %`  <ul class="tab-control">  `
    @tab_panel_context_arr.each_with_index do |hash,index|
      title = hash[:title]
      if hash[:href]
        title = %`  <a data-url="#{hash[:href]}" data-tip="#{hash[:tip]}">#{title}</a>  `
      end
      ul << %`
        <li id="#{hash[:id]}" class="tab-control-li #{index == 0 ? "tab-selected" : ""}">
          #{title}
        </li>
      `
    end
    ul << "</ul>"

    div = %`  <div class="tab-panel-set">  `
    @tab_panel_context_arr.each_with_index do |hash,index|
      div << %`
        <div class="tab-panel-item" style="#{index !=0 ? "display: none;" : ""}">
          #{hash[:content]}
        </div>
      `
    end
    div << "</div>"

    str = %`  <div class="tab-panel" id="#{id}">  `
    str << ul
    str << div
    str << "</div>"
    @tab_panel_context_arr = []
    concat(str)
  end

  def tabi(*args,&block)
    title = args.first
    content = capture(&block) if block
    options = args.extract_options!
    href = options[:href]
    tip = options[:tip] || title
    id = options[:id]
    @tab_panel_context_arr ||= []
    if href.nil?
      @tab_panel_context_arr << {:id=>id,:title=>title,:content=>content}
    else
      @tab_panel_context_arr << {:id=>id,:title=>title,:href=>href,:tip=>tip}
    end
  end


  def bar_panel(*args,&block)
    options = args.extract_options!
    id = options[:id]
    block.call()
    str = %`
      <ul class="tab-control">
      #{@bar_panel_content}
      </ul>
    `
    @bar_panel_content = ""
    concat(str)
  end

  def bari(*args)
    title = args.first
    options = args.extract_options!
    url = options[:url]
    selected = @controller.request.request_uri == url
    selected_class = selected ? "tab-selected" : ""
    content = link_to title,url
    content = title if selected
    @bar_panel_content ||= ""
    @bar_panel_content << %`
      <li class="tab-control-li #{selected_class}">
        #{content}
      </li>
    `
  end
end
