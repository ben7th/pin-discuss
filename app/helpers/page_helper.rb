module PageHelper
  def round_edge(edge=:top,options=Hash.new(''))
    width = options[:width]
    color = options[:color] || ''
    bcolor = options[:bcolor] || color
    htmlclass = options[:class].blank? ? '':" #{options[:class]}"
    arr=[
      "<div class='round_corner_level_1#{htmlclass}' style='background-color:#{color};border-left:solid 1px #{bcolor};border-right:solid 1px #{bcolor};'></div>",
      "<div class='round_corner_level_2#{htmlclass}' style='background-color:#{color};border-left:solid 2px #{bcolor};border-right:solid 2px #{bcolor};'></div>",
      "<div class='round_corner_level_3#{htmlclass}' style='background-color:#{color};border-left:solid 1px #{bcolor};border-right:solid 1px #{bcolor};'></div>",
      "<div class='round_corner_level_4#{htmlclass}' style='background-color:#{color};border-left:solid 1px #{bcolor};border-right:solid 1px #{bcolor};'></div>"
    ]
    re = arr*'' if edge==:top
    re = arr.reverse*'' if edge==:bottom
    "<div class='round_corner_container' style='width:#{prepare_width(width)}'>"+
      re+
      "</div>"
  end

  def prepare_width(width)
    return width if width.to_s.last == '%'
    return "#{width}px"
  end

  def round_container(options=Hash.new(''),&block)
    content = capture(&block)
    top_color = options[:topcolor] || options[:color]
    bottom_color = options[:bottomcolor] || options[:color]
    concat(round_edge(:top,options.merge(:color=>top_color))) if options[:topcolor] != '' && options[:color] != ''
    concat(content)
    concat(round_edge(:bottom,options.merge(:color=>bottom_color))) if options[:bottomcolor] != '' && options[:color] != ''
  end

  # 生成render :partial=>'xxx/_meta_xxx',:locals=>{:xxx=>xxx}
  def meta(instance)
    return I18n.t("page.tags.object_deleted") if instance.blank?
    begin
      klass = instance.class
      path = get_partial_of_class("meta",klass)
      return (render :partial=>path,:locals=>{klass.name.demodulize.underscore.to_sym=>instance})
    rescue Exception => ex
      return ex
    end
  end

  # 获取当前页面显示主题字符串，如果没有默认是 'sapphire'
  def get_user_theme_str
    if @mindpin_layout.theme.blank?
      user = current_user

      # 个人主页特殊处理
      if [controller_name,action_name] == ["users","show"]
        user = User.find(params[:id])
      end

      return "sapphire" if user.blank?

      user.create_preference if user.preference.blank?
      theme = user.preference.theme
      theme = "sapphire" if theme.blank?
      return theme
    else
      @mindpin_layout.theme
    end
  end

  # 获取页面布局的grid样式名
  def get_grid_classname
    if @mindpin_layout.grid
      return "container_#{@mindpin_layout.grid}"
    end
    return nil
  end

  # 加载页面布局的gridcss文件
  def grid_css
    case @mindpin_layout.grid
    when 24
      stylesheet_link_tag 'framework/grid_960_24',:media=>'screen, projection'
    when 19
      stylesheet_link_tag 'framework/grid_760_19',:media=>'screen, projection'
    when 'auto'
      stylesheet_link_tag 'framework/grid_auto',:media=>'screen, projection'
    end
  end

  # 加载css文件
  def require_css(cssname, iefix = false)
    render :partial=>'layouts/parts/require_css',:locals=>{:cssname=>cssname,:iefix=>iefix}
  end

end
