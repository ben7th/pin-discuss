module ImagesHelper
  # 无链接的logo
  def logo(model,style=nil,id=nil)
    style_str = style.nil? ? '':"_#{style}"
    unless model.blank?
      "<img alt='#{get_visable_name(model)}' class='logo #{style}' id='logo_#{dom_id(model)}#{style_str}' src='#{model.logo.url(style)}'/>"
    else
      "<img alt='#{get_visable_name(model)}' class='logo #{style}' src='/images/logo/default_unknown_#{style}.png'/>"
    end
  end
  
  # 带链接的user logo
  def user_logo_link(user)
    link_to logo(user),user,:title=>"查看#{user.name}的档案"
  end

  def logolink(model,style=nil)
    link_to((logo model,style),model,:class=>'logolink',:title=>get_visable_name(model))
  end

  def logolink_special(model)
    link_to("<img class='logo' src='#{model.logo_url}'/>",model,:class=>'logolink')
  end

  # user logo&name的标签
  def user_label(user,showname=true)
    if(showname)
      "<dl class='pinu'><dt>#{logo user}</dt><dd>#{user.name}</dd></dl>"
    else
      "<dl class='pinu'><dt>#{logo user}</dt></dl>"
    end
  end

  def user_div(user)
    %~
      <div class="uv">
        <div class="l">#{logo user}</div>
        <div class="n">#{qlink user}</div>
      </div>
    ~
  end

  def user_card(user,options={:width=>180,:info=>nil})
    %Q{
      <div class='boxfix' style='width:#{options[:width]}px;height:60px;'>
        <div class="uv">
          <div class="l">#{logo user}</div>
        </div>
        <div class='fleft' style='width:120px;'>
          <div>#{qlink user}</div>
          <div class='quiet'>#{options[:info] || "#{created_at user}加入"}</div>
        </div>
      </div>
    }
  end

  def image_center_div(img,width=100,height=100)
    re="<div class='image_center_div' style='width:#{width}px;height:#{height}px;'>"
    re+="<p>"
    re+=img
    re+="</p>"
    re+="</div>"
    return re
  end
end
