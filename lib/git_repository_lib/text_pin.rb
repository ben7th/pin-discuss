require 'uuidtools'

class TextPin < MplistRecord
  attr_reader :id,:struct,:repo_user_id,:repo_name,:created_at,:email,:commit_id
  attr_writer :struct,:created_at,:email
  SUB_PATH = "text"

  def initialize(options)
    @attrs = options
    @attrs.each{ |name,value| self.instance_variable_set("@#{name}", value)}
  end

  # 根据id找到文本资源
  def self.find(options)
    id = options[:id]
    repo_user_id = options[:repo_user_id]
    repo_name = options[:repo_name]
    commit_id = (options[:commit_id] || "master")
    file_info = GitRepository.find(repo_user_id,repo_name).show_file(commit_id,File.join(SUB_PATH,id))
    TextPin.build_from_file_info(file_info)
  end

  # 根据一个file_info组装一个text_pin
  def self.build_from_file_info(file_info)
    repo = file_info.repo
    _email = file_info.repo_commit.email
    
    TextPin.new(:repo_user_id=>repo.user.id,:repo_name=>repo.name,:id=>file_info.name,:commit_id=>file_info.repo_commit.id,
      :struct=>file_info.data,:created_at=>file_info.repo_commit.date,:email=>_email)
  end

  # 所有提交的历史记录
  def versions
    gr = GitRepository.find(self.repo_user_id,self.repo_name)
    gr.commits(sub_path).map{|commit|
      file_info = gr.show_file(commit.id,sub_path)
      TextPin.build_from_file_info(file_info)
    }
  end

  # 历史编辑信息
  # {:users=>users,:count=>count}
  # users 除去最新版本的所有编辑者
  # count 除去最新版本的所有编辑次数
  def edit_info
    gr = GitRepository.find(self.repo_user_id,self.repo_name)
    history_commits = gr.commits(sub_path)
    history_commits.shift
    return if history_commits.count == 0
    {:editors=>history_commits.map{|commit|User.find_by_email(commit.email)}.uniq,:count=>history_commits.count}
  end

  # 保留，这个属性记录了 这个 text_pin 的版本库硬盘路径
  #  def path_id
  #    URI.escape("users/#{@user_id}/#{@repo_name}/#{SUB_PATH}/#{self.file_name}","/ .")
  #  end

  # 在版本库中的相对路径
  def sub_path
    File.join(SUB_PATH,self.id)
  end

  #  # 检测是否通过验证
  #  def valid?
  #    @errors = {}
  #    @errors.merge!('content'=>"内容不能为空") if content.blank?
  #    @errors.merge!('repo_user_id'=>"内容不能为空") if repo_user_id.blank?
  #    @errors.merge!('creator'=>"内容不能为空") if creator.blank?
  #    @errors.blank?
  #  end
  #
  #  # 错误信息
  #  def errors
  #    @errors ||= {}
  #  end

  def plain_content
    Nokogiri::XML(@struct).at_css("content").text
  end

  # 处理文本信息
  def content_array
    xml_content = Nokogiri.XML(self.struct)
    text = xml_content.at("content").text
    text.chars.to_a
  end

  # 解析content的格式信息
  def formats
    xml_content = Nokogiri.XML(self.struct)
    formats_node = xml_content.at("format")
    formats = formats_node.css("*").map do |child|
      {:style=>child.name,:from=>child[:from],:to=>child[:to]}
    end.compact
    Format.build(formats)
  end

  def to_html
    content_tmp = content_array
    formats.each do |format|
      item_from = content_tmp[format.from.to_i-1]
      content_tmp[format.from.to_i-1] = "#{format.prex_tag}#{item_from}"
      item_to = content_tmp[format.to.to_i-1]
      content_tmp[format.to.to_i-1] = "#{item_to}#{format.suffix_tag}"
    end
    (content_tmp*"").gsub("\n","<br/>")
  end

  # 把 纯文本字符串转化成 text_pin 的 xml 格式
  def self.init_xml(text_pin)
    plain,format_str = "",""
    if text_pin[:content]
      plain = text_pin[:content]
      formats = text_pin[:format]
      formats = self.params_formats_to_hash_array(formats) if formats.is_a?(String)
      format_str = (formats || []).map do |item|
        %`<#{item[:type]} from='#{item[:from]}' to='#{item[:to]}' />`
      end*""
    elsif text_pin[:html]
      res = HTMLParse.parse(text_pin[:html])
      plain = res[:plain]
      format_str = res[:formats].map do |item|
        item[:style].map do|style|
          %`<#{style} from='#{item[:from]}' to='#{item[:to]}' />`
        end*""
      end*""
    end
    %`
      <text>
        <content><![CDATA[#{plain}]]></content>
        <format>
          #{format_str}
        </format>
      </text>
    `
  end

  # 临时处理，format的格式暂时定义为
  def self.params_formats_to_hash_array(formats)
    formats.split("\n").map do |str_format|
      items = str_format.split("|")
      {:type=>items[0],:from=>items[1],:to=>items[2]}
    end.compact
  end

  # 显示格式的类
  class Format
    attr_reader :kinds,:from,:to
    def initialize(from,to,kinds)
      @from, @to, @kinds = from, to, kinds
      
      @kinds_style = @kinds.map do |kind|
        case kind
        when "bold" then "font-weight:bold"
        when "italic" then "font-style:italic"
        else kind
        end
      end*";" + ";"
    end

    def suffix_tag
      "</span>"
    end

    def prex_tag
      "<span style='#{@kinds_style}'>"
    end

    # {:style=>"bold",:from=>1,:to=>1}
    # {:style=>"italic",:from=>1,:to=>1}
    def self.build(formats)
      temp_arr = []
      until formats.size == 0
        current_hash = formats.shift
        overlaps = self.find_overlaps(current_hash,formats)
        styles = overlaps.map{|hash|hash[:style]}
        styles << current_hash[:style]
        temp_arr << {:from=>current_hash[:from],:to=>current_hash[:to],:style=>styles}
        formats = formats - overlaps
      end
      temp_arr.map {|hash|Format.new(hash[:from],hash[:to],hash[:style])}
    end

    def self.find_overlaps(current_hash,formats)
      formats.select { |format| overlap?(format,current_hash)}
    end

    def self.overlap?(format,current_hash)
      format[:from] == current_hash[:from] && format[:to] == current_hash[:to]
    end
  end
end