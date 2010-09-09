module LinkHelper

  def creator_name_of(model)
    return "<span style='color:#999;'>#{get_visable_name(model.creator)}</span>" if model.creator.blank?
    get_visable_name model.creator
  end

  def get_visable_name(model)
    return t("page.teaching.procedure_posts.has_deleted") if model.blank?
    begin
      model.name
    rescue NoMethodError
      model.title
    end
  end

  # 快速异步请求链接
  def qlink_remote(model,options = {},html_options = nil)
    return "<span style='color:#999;'>[已删除]</span>" if model.blank?
    name = get_visable_name(model)
    options[:title] ||= name
    options[:class] = 'username' if model.instance_of?(User)
    options[:url] ||= url_for(model)
    options[:method] ||= :get
    options[:create] = 'show_ajax_info()'
    options[:success] = 'show_ajax_info({mode:"success"})'
    options[:failure] = 'show_ajax_info({mode:"failure"})'
    length = options[:length] || 20

    html_options = {:href=>url_for(model)}

    link_to_remote h(truncate_u(name,length)),options,html_options
  end

  def qlink(model,options = {})
    qlink_truncate(model,options)
  end

  # 快速生成模型链接，并截取限定长度的字符串
  def qlink_truncate(model,options = {})
    return "<span style='color:#999;'>[已删除]</span>" if model.blank?
    name = get_visable_name(model)
    options[:title] = name if options[:title].blank?

    icon_clazz = options[:icon]==true ? " icon_#{model.class.name.underscore.gsub('/','_')}":''
    options.delete(:icon)
    options[:class] = "#{options[:class]}#{icon_clazz}"

    options[:class] = 'username' if model.instance_of?(User)

    length = options[:length] || 20

    link_to ERB::Util.h(truncate_u(name,length)),model,options
  end

  # 生成图片按钮形式的链接
  def ibtn_link_to(*args)
    build_ibtn_link_dom(false,*args)
  end

  # 生成图片按钮形式的链接
  def ibtn_link_to_remote(*args)
    build_ibtn_link_dom(true,*args)
  end

  # private
  # 构建ibtn链接所需要的html
  # options 参数
  # :method 默认为:get
  # :url
  # :class
  # :position 默认为 :left
  # :set 值为 :collection | :member 默认为 :collection
  def build_ibtn_link_dom(remote=true,*args)
    name, options, html_options = args.first, (args.second||{}), (args.third||{})

    options[:method] ||=:get
    html_options[:href] ||= url_for options[:url]

    clazz = html_options[:class]
    clazz = clazz.blank? ? 'hidetext':"#{clazz} hidetext"

    position = options[:position] || :left

    set = options[:set] || :collection

    if remote
      return <<EOF
        <div class='img-button #{position} #{set}'>
          #{link_to_remote('',options,html_options.merge(:class=>clazz,:title=>name))}
        </div>
EOF
    end
    return <<EOF
      <div class='img-button #{position} #{set}'>
        #{link_to('',options,html_options.merge(:class=>clazz,:title=>name))}
      </div>
EOF
  end

  # user快速链接
  def ulink(user)
    link_to h(current_user==user ? '您' : user.name),user
  end

  # user数组快速链接
  def ulinks(users)
    users.map{|u| ulink u}.join(', ')
  end
  
  ##########################

  def link_to_active(name, options = {}, html_options = {}, &block)
    if(current_page?(options))
      html_options[:class] = "active #{html_options[:class]}"
    end
    link_to name, options, html_options, &block
  end

  def link_to_active_if(condition, name, options = {}, html_options = {}, &block)
    if condition
      html_options[:class] = "active #{html_options[:class]}"
    end
    link_to name, options, html_options, &block
  end

  def link_to_active_within(enum, name, options = {}, html_options = {}, &block)
    if enum.include?([controller.controller_name,controller.action_name])
      html_options[:class] = "active #{html_options[:class]}"
    end
    link_to name, options, html_options, &block
  end

  def finder_link(name,key,value,default=false)
    # 检查url里面是否包含当前条件
    if(include_query?(key,value))
      # 如果完整包含当前条件 key=value 则返回selected
      link_to(name,finder_url(key,value),:class=>'selected')
    elsif(!include_query_key?(key)&&default)
      # 或者不包含当前key，且当前value是默认值，也返回selected
      link_to(name,finder_url(key,value),:class=>'selected')
    else
      link_to(name,finder_url(key,value))
    end
  end

  # 生成页面分类选择器用到的链接
  # 在页面上的分类选择器中，选择某个维度下的一个分类后
  # 在新显示的页面中，所有分类选择链接都要产生相应变化
  # 例如原本为 www.example.com
  # 则变为 www.example.com?a=1
  # 例如原本为 www.example.com?b=1
  # 则变为 www.example.com?b=1&a=1
  # 用法： finder_url('a','1') 则在原本的url参数里增加 a=1 这一项。
  # 会自动考虑 & 和 ? 的情况
  def finder_url(key,value,option={})
    uri=request.request_uri.clone
    except_page = option[:except_page]
    except_page = true if except_page.nil?
    uri = uri.remove_url_param('page') if except_page
    uri = uri.remove_url_param('PLpos').remove_url_param('authenticity_token')
    if(value.blank?)
      uri.sub(Regexp.new("#{'(\&'}#{key}#{'=)(\w+)'}"),'').sub(Regexp.new("#{'(\?'}#{key}#{'=)(\w+)'}"),'?').sub('?&','?').sub(/\?$/,'')
    else
      unless (uri.sub!(Regexp.new("#{'((\?|\&)'}#{key}#{'=)(\w+)'}"),'\1'+value.to_s)).nil?
        uri
      else
        if uri.match(/\?/)
          "#{uri}&#{key}=#{value}"
        else
          "#{uri}?#{key}=#{value}"
        end
      end
    end
  end

  def include_query_key?(key)
    kvs = URI.parse(request.url).query
    if kvs.nil?
        return false
    else
      kvsa = kvs.split('&')
      kvsa.map{|kv| kv.split('=')[0]}.include?(key)
    end
  end

  def include_query?(key,value)
    kvs = URI.parse(request.url).query
    if kvs.nil?
      return false
    else
      kvsa = kvs.split('&')
      return (kvsa.include?("#{key}=#{value}"))
    end
  end

  def title_with_link(title,link)
    "<span style='float:left;'>#{title}</span><span style='float:right'>#{link}</span>"
  end

#  def action(*args, &block)
#    "<p class='walk1'>&gt; <span>#{link_to(*args, &block)}</span></p>"
#  end

  def show_box(selector_str, options={}, &block)
    add_javascript '/javascripts/glassbox/glassbox.js'
    content = capture(&block)
    width = options[:width] || 400
    height = options[:height] || 300
    opacity = options[:opacity] || 0.1

    afterload = options[:afterload] || ''
    onclose = options[:onclose] || ''
    id = options[:id]

    concat(render :partial=>'layouts/jsutil/show_box',:locals=>{
        :selector_str=>selector_str,
        :content=>content,
        :width=>width,
        :height=>height,
        :opacity=>opacity,
        :afterload=>afterload,
        :onclose=>onclose,
        :domid=>id
      })
  end

#  # 创建带红色图标的动作链接
#  # 已废弃
#  def maction_r(content,options={})
#    "<span class='action' style='#{options[:style]}'><span class='icon_r'>&gt;</span><span class='link'>#{content}</span></span>"
#  end

  def pin_url_u(pin)
    "/pins/#{pin.class}:#{pin.id}"
  end

  def selector_link_to(name, options = {}, html_options = {}, &block)
    classname = current_page?(options) ? 'page-selector url-active':'page-selector'
    %~
      <div class='#{classname}'>
        #{link_to name, options, html_options, &block}
      </div>
    ~
  end

end
