module UiAccordionHelper
  def accordion_bar(*args,&block)
    options = args.extract_options!
    id = options[:id] || ""
    global_active_bgc = options[:active_bgc] || ""
    global_bgc = options[:bgc] || ""


    block.call()

    id_str = id.blank? ? "" : "id='#{id}'"

    bar_str = %`  <div #{id_str} class="mpaccordion-bar">  `
    @mpaccordion_bar_context_arr.each do |hash|
      title = hash[:title]
      content = hash[:content]
      open = hash[:open]
      active_bgc = hash[:active_bgc]
      active_bgc = active_bgc.blank? ? global_active_bgc : active_bgc
      bgc = hash[:bgc]
      bgc = bgc.blank? ? global_bgc : bgc
      bgc_str = bgc.blank? ? "" : "background-color:#{bgc};"
      active_bgc_str = active_bgc.blank? ? "" : "background-color:#{active_bgc};"


      data_active_bgc_str = active_bgc.blank? ? "" : "data-active-bgc='#{active_bgc}'"
      data_bgc_str = bgc.blank? ? "" : "data-bgc='#{bgc}'"

      bgc_style = open ? active_bgc_str : bgc_str
      open_class = open ? "mpaccordion-opened" : "mpaccordion-unopen"
      bar_str << %`
        <div class="mpaccordion-toggler #{open_class}" style="#{bgc_style}" #{data_active_bgc_str} #{data_bgc_str}>
              #{title}
        </div>
      `
      height_style = open ? "" : "height:0px;"
      bar_str << %`
        <div class="mpaccordion-content" style="#{height_style}">
          #{content}
        </div>
      `
    end
    bar_str << "</div>"

    @mpaccordion_bar_context_arr = []
    concat(bar_str)
  end

  def accordion_item(*args,&block)
    title = args.first
    options = args.extract_options!
    content = capture(&block) if block
    active_bgc = options[:active_bgc] || ""
    bgc = options[:bgc] || ""
    open = options[:open] || false
    
    @mpaccordion_bar_context_arr ||= []
    @mpaccordion_bar_context_arr << {:title=>title,:content=>content,:bgc=>bgc,:active_bgc=>active_bgc,:open=>open}
  end
end
