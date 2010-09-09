class String
  def get_url_params_hash
    tmp = self.split('?')
    tmp = tmp.length>1 ? Hash[*(tmp[-1].split(/&|=/,-1))]:{}
  end

  def add_url_param(k,v)
    hash = self.get_url_params_hash
    hash[k] = v
    if self.include?('?')
      tmp = self.split('?')[-2]
    else
      tmp = self
    end
    "#{tmp}?#{CGI.unescape hash.to_param}"
  end

  # 移除url查询字符串中的键
  def remove_url_param(key)
    hash = self.get_url_params_hash
    unless hash=={}
      hash.delete(key)
      tmp = CGI.escape self.split('?')[-2]
      re = CGI.unescape(hash.length > 0 ? "#{tmp}?#{hash.to_param}":"#{tmp}")
    else
      re = self
    end
    re
  end

  def remove_mindpin_token
    if(self.include? '?')
      self.remove_url_param('app_token').remove_url_param('req_user_id').remove_url_param('api_token').remove_url_param('app')
    else
      self
    end
  end

  # 用户名字符串->用户数组
  def to_users
    User.find_all_by_name(self.split(','))
  end

  # 把 UTF-8 转换成 GBK
  def utf8_to_gbk
    Iconv.conv("gbk","utf-8",self)
  end

  # 把 GBK 转换成  UTF-8
  def gbk_to_utf8
    Iconv.conv("utf-8","gbk",self)
  end

  def to_utf8(charset)
    Iconv.conv("utf-8",charset,self)
  end

  def utf8_to(charset)
    Iconv.conv(charset,"utf-8",self)
  end

  # 举例 "abc"=>["a","ab","abc"]
  # 举例 "大家好"=>["大","大家","大家好"]
  def to_prefixs
    str_arr = self.split('')
    results = []
    str_arr.each_with_index do |str, index|
      prefix_arr = str_arr[0..index]
      results << prefix_arr*""
    end
    return results
  end

  # 允许字符创中下面的标签出现
  def sanitize_clean
    rule = {
      :elements => [
        'a', 'b', 'blockquote', 'br', 'caption', 'cite', 'code', 'col',
        'colgroup', 'dd', 'dl', 'dt', 'em', 'h1', 'h2', 'h3', 'h4', 'h5', 'h6',
        'i', 'img', 'li', 'ol', 'p', 'pre', 'q', 'small', 'strike', 'strong',
        'sub', 'sup', 'table', 'tbody', 'td', 'tfoot', 'th', 'thead', 'tr', 'u',
        'ul','span','div'],

      :attributes => {
        'a'          => ['href', 'title'],
        'blockquote' => ['cite'],
        'col'        => ['span', 'width'],
        'colgroup'   => ['span', 'width'],
        'img'        => ['align', 'alt', 'height', 'src', 'title', 'width'],
        'ol'         => ['start', 'type'],
        'q'          => ['cite'],
        'table'      => ['summary', 'width'],
        'td'         => ['abbr', 'axis', 'colspan', 'rowspan', 'width'],
        'th'         => ['abbr', 'axis', 'colspan', 'rowspan', 'scope',
          'width'],
        'ul'         => ['type']
      },

      :protocols => {
        'a'          => {'href' => ['ftp', 'http', 'https', 'mailto',
            :relative]},
        'blockquote' => {'cite' => ['http', 'https', :relative]},
        'img'        => {'src'  => ['http', 'https', :relative]},
        'q'          => {'cite' => ['http', 'https', :relative]}
      }
    }

    Sanitize.clean(self,rule)
  end

  # 将字符创中所有的标签全部去掉
  def sanitize_clean_all
    self.gsub(/<\/?[^>]*>/,  "")
  end

  def url_to_site
    ip_match = /^(([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])\.){3}([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])$/
    host = URI.parse(self).host
    # IP 地址
    if ip_match.match(host)
      return host
    end
    # stackoverflow.com
    if host.split(".").length == 2
      return host
    end
    str_arr = host.split(".")
    str_arr.shift
    return str_arr*"."
  end

  # 根据url得到这个地址的domain
  def url_to_domain
    URI.parse(self).host
  end

  def markdown_paragraphs
    # 把 \t 转换成 四个空格
    self.gsub!(/\t/,"    ")
    # 整行空格去掉
    self.gsub!(/^ +$/,"")
    # 把换行统一成 \n
    self.gsub!(/\r\n/,"\n")
    # 去掉文章开头的无意义回车
    self.gsub!(/\A\n+/,"")
    str_arr = self.split(/^#/)
    # 如果 内容是 #
    return [self] if str_arr.length == 0
    # 如果没有分段
    return [self] if str_arr.length == 1
    first_paragraph = str_arr.shift
    str_arr.map! { |str| "##{str}"}
    str_arr.unshift(first_paragraph) if first_paragraph != ""
    # 看内容是否以  \n\# 结束
    if self[-2..self.length] == "\n#"
      str_arr.push("#")
    end
    return str_arr
  end

  def markdown_to_html
    BlueCloth.new(self).to_html
  end
end

def randstr(length=8)
  base = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
  size = base.size
  re = ''<<base[rand(size-10)]
  (length-1).times  do
    re<<base[rand(size)]
  end
  re
end

def text_num(text,num)
  num == 0 ? "#{text}" : "#{text}(#{num})"
end
