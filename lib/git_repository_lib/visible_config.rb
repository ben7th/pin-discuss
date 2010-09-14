class VisibleConfig

  SUB_PATH = "visable_config"

  attr_reader :struct
  def initialize(options)
    @struct = options[:struct]
  end

  # <invisible user='fushang318@126.com' tid='xxxxxxx'>
  # <invisible user='ben7th@sina.com' tuser='aaa@bbb.com'>
  def self.init_xml
    %`
    <config>
      <texts>
      </texts>
      <users>
      </users>
    </config>
    `
  end

  def self.build_from_file_info(file_info)
    struct = file_info.data
    self.new(:struct=>struct)
  end

  # 人 屏蔽 文本 的所有规则
  # 返回结果的格式为{:文本id=>[屏蔽者1,屏蔽者2],:文本id=>[屏蔽者1,屏蔽者2]}
  def texts_visibles
    return @texts_visibles if @texts_visibles
    hash = {}
    Nokogiri::XML(struct).css('texts invisible').each do |invisible|
      tid = invisible['tid']
      user = invisible['user']
      if hash.key?(tid)
        hash[tid] << user
        next
      end
      hash[tid] = [user]
    end
    @texts_visibles = hash
  end

  # 检查某个人对某个text_pin的可见状态
  def tu_visible_for?(text_pin_id,observer)
    !(texts_visibles[text_pin_id] && texts_visibles[text_pin_id].include?(observer))
  end

  # 人 屏蔽 人 的所有规则
  # 返回结果的格式为{:作者=>[屏蔽者1,屏蔽者2],:作者=>[屏蔽者1,屏蔽者2]}
  def users_visibles
    return @users_visibles if @users_visibles
    hash = {}
    Nokogiri::XML(struct).css('users invisible').each do |invisible|
      author = invisible['tuser']
      user = invisible['user']
      if hash.key?(author)
        hash[author] << user
        next
      end
      hash[author] = [user]
    end
    @users_visibles = hash
  end

  # 检查某个人对某作者的可见状态
  def uu_visible_for?(temail,observer_email)
    !(users_visibles[temail] && users_visibles[temail].include?(observer_email))
  end
  
end
