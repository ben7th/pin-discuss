# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper

  def is_ie?
    /MSIE 6/.match(request.user_agent)
  end

  def is_ff?
    /Firefox/.match(request.user_agent)
  end

  # 清除一段文本中的html标签
  def clear_html(text,replacement='')
    (text||'').gsub(/<[^>]*>/){|html| replacement}
  end

  # utf8下将中文当成两个字符处理的自定义的truncate方法
  # 取自javaeye上庄表伟和quake wang的方法
  # 由于quake wang的方法在需要截取的字符数大于30时有较严重的效率问题，导致卡死进程
  # 因此需要截取长度大于30时使用庄表伟的方法
  def truncate_u(text, length = 30, truncate_string = "...")
    if length >= 30
      l=0
      char_array=text.unpack("U*")
      char_array.each_with_index do |c,i|
        l = l+ (c<127 ? 0.5 : 1)
        if l>=length
          return char_array[0..i].pack("U*")+(i<char_array.length-1 ? truncate_string : "")
        end
      end
      return text
    else
      if r = Regexp.new("(?:(?:[^\xe0-\xef\x80-\xbf]{1,2})|(?:[\xe0-\xef][\x80-\xbf][\x80-\xbf])){#{length}}", true, 'n').match(text)
        return r[0].length < text.length ? r[0] + truncate_string : r[0]
      else
        return text
      end
    end
  end

  def truncate_filename(filename,length = 4)
    # 把文件名从 . 切开成数组，并把 . 保留
    # 例如 "1.txt"=>["1",".","txt"]
    old_names = filename.split(/(\.)/)
    if old_names[-2] == '.'
      # 有后缀名
      base_name = old_names[0...-2]*""
      suffix_name = old_names[-2..-1]*""
      return "#{truncate_u(base_name,length)}#{suffix_name}"
    else
      # 没有后缀名
      return "#{truncate_u(old_names*"",length)}"
    end
  end

  # 摘要
  def brief(text)
    "　　"<<h(truncate_u(text,28))
  end

  # 对纯文本字符串进行格式化，增加中文段首缩进，以便于阅读
  def group_content_format(content,indent=0)
    indent_str = '　'*indent
    simple_format(h(content)).gsub("<p>", "#{indent_str}<p>").gsub("<br />","#{indent_str}<br />")
  end

  def ct(content)
    group_content_format(content)
  end

  def hr
    "<div class='hr'><hr /></div>"
  end

  # 给当前页增加RSS FEED链接
  def rssfeed
    link_to "<img src='/images/rss.png' style='vertical-align:text-bottom'>","#{request.url.sub(/\/$/,"")}.rss"
  end

  # 计算回复数 如果没有回复则为空
  def count_reply(size)
    size>1?size-1:''
  end

  # 以中文式引号围绕
  def cn_quote(str)
    "<img src='/images/s.gif' class='quote-left'/>#{str}<img src='/images/s.gif' class='quote-right'/>"
  end

  # 搜索结果高亮字符串转义
  def h_highlight(str)
    (h str).gsub('&lt;span class=&quot;highlight&quot;&gt;','<span class="highlight">').gsub('&lt;/span&gt;','</span>')
  end

  #i 原始数 n 要保留的小数位数，flag=1 四舍五入 flag=0 不四舍五入
  def _4s5r(i,n=2,flag=1)
    return 0 if i.blank?
    i = i.to_f
    y = 1
    n.times do |x|
      y = y*10
    end
    if flag==1
      (i*y).round/(y*1.0)
    else
      (i*y).floor/(y*1.0)
    end
  end

  def attr(key,value,options={})
    "<div class='attr' style='#{options[:style]}'><div class='key quiet' style='#{options[:keystyle]}'>#{key}</div><div class='value' style='#{options[:valuestyle]}'>#{value}</div></div>"
  end

  def attr60(key,value,options={})
    "<div class='attr'><div class='key60 quiet' style='#{options[:keystyle]}'>#{key}</div><div class='value' style='#{options[:valuestyle]}'>#{value}</div></div>"
  end

  def pbr(padding)
    "<div style='oveflow:hidden;height:#{padding}px'></div>"
  end

  # 根据传入的百分比数值，显示百分比条
  def percentage_bar(percentage,options={:width=>'88'})
    if !percentage.blank?
      width = options[:width]
      <<EOF
      <div class='percentage_bar' style='width:#{width}px;'>
        <div style="width:#{percentage};"></div>
      </div>
EOF
    end
  end
end