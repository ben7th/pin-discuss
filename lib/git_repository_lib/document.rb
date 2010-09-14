require 'uuidtools'
class Document < MplistRecord

  SUB_PATH = "document_tree"

  attr_reader :id,:repo_user_id,:creator,:repo_name,:struct,:commit_id,:text_pin
  attr_writer :id
  def initialize(options)
    @repo_name = options[:repo_name]
    @repo_user_id = options[:repo_user_id]
    @commit_id = options[:commit_id]
    @text_pin = options[:text_pin]
    @creator = options[:creator]
    @struct = options[:struct]
    @id = options[:id]
    @nokogiri_struct = Nokogiri::XML(@struct) if !@struct.blank?
  end

  # 在数据库中对应的document_tree
  def document_tree
    Discussion.find(self.id)
  end

  # 在版本库中的相对路径
  def sub_path
    File.join(SUB_PATH,self.id)
  end

  def self.create_valid?(options)
    self.create_valid_error(options).blank?
  end

  def self.create_valid_error(options)
    options.symbolize_keys!
    errors = {}
    text_pin = options[:text_pin]
    errors.merge!('text_pin'=>"text_pin 不能为空") if text_pin.blank?
    errors.merge!('text_pin[:content]'=>"text_pin 的 content 不能为空") if text_pin && !(text_pin[:content] || text_pin[:html])
    errors.merge!('creator'=>"creator 不能为空") if options[:creator].blank?
    errors.merge!('repo_name'=>"repo_name 不能为空") if options[:repo_name].blank?
    errors
  end
  
  # 创建一个 讨论
  def self.create(options)
    if self.create_valid?(options)
      document = Document.new(options)
      document_tree = Discussion.create(:workspace_id=>document.repo_name)
      document_id = document_tree.id.to_s
      document.id = document_id
      text_pin_id = UUIDTools::UUID.random_create.to_s
      text_xml = TextPin.init_xml(document.text_pin)
      document_xml = Document.init_xml(document.creator.email,text_pin_id)
      visible_xml = VisibleConfig.init_xml
      data_and_tos = [
        {:data=>text_xml,:to=>File.join(TextPin::SUB_PATH,text_pin_id)},
        {:data=>document_xml,:to=>File.join(Document::SUB_PATH,document_id)},
        {:data=>visible_xml,:to=>File.join(VisibleConfig::SUB_PATH,document_id)}
      ]
      document.commit_files_and_create_discussion_and_document_message(data_and_tos,document.creator,text_pin_id,options[:mmid])
      return document.find_from_repository
    end
    return false
  end
  
  # 在一个讨论中进行回复
  # document.reply(:mmid=>***,:text_pin_id=>text_pin.id,:user=>lucy,:text_pin=>{:content=>reply_content})
  def reply(options)
    text_pin_id = options[:text_pin_id]
    user = options[:user]

    return false if user.blank?
    new_pin_id = UUIDTools::UUID.random_create.to_s
    text_xml = TextPin.init_xml(options[:text_pin])

    add_joiner_to_struct(user)
    add_text_pin_to_struct(new_pin_id,text_pin_id).to_s
    document_xml = @nokogiri_struct.to_s

    params = [
      {:data=>text_xml,:to=>File.join(TextPin::SUB_PATH,new_pin_id)},
      {:data=>document_xml,:to=>File.join(Document::SUB_PATH,self.id)}
    ]
    commit_files_and_create_discussion_and_document_message(params,user,new_pin_id,options[:mmid])
    return find_from_repository.find_text_pin(new_pin_id)
  end

  def commit_files_and_create_discussion_and_document_message(params,user,text_pin_id,mmid)
    commit_files_to_repository(params, user)
    add_discussion(user)
    create_document_message(text_pin_id,mmid)
  end

  def create_document_message(text_pin_id,mmid)
    DocumentMessage.create(:document_tree_id=>self.id,:text_pin_id=>text_pin_id,:mmid=>mmid)
  end

  def git_repo
    GitRepository.find(self.repo_user_id,self.repo_name)
  end

  def find_from_repository
    Document.find(:creator=>self.creator,:repo_user_id=>self.repo_user_id,:repo_name=>self.repo_name,:id=>self.id)
  end

  def reload
    find_from_repository
  end

  # 根据 id,repo_name,repo_user_id 找到一个讨论
  def self.find(options)
    id = options[:id]
    repo_user_id = options[:repo_user_id]
    repo_name = options[:repo_name]
    file_info = GitRepository.find(repo_user_id,repo_name).show_file("master",File.join(SUB_PATH,id))
    Document.build_from_file_info(file_info)
  end

  # 找到一个版本库中的所有讨论
  def self.find_all_in_repo(user_id,repo_name)
    repo = GitRepository.find(user_id,repo_name)
    repo.show("master",SUB_PATH).map do |file_info|
      Document.build_from_file_info(file_info)
    end
  end

  # 根据一个file_info组装一个document
  def self.build_from_file_info(file_info)
    repo = file_info.repo
    _creator = User.find_by_email(file_info.repo_commit.email)
    self.new(:repo_user_id=>repo.user.id,:repo_name=>repo.name,:id=>file_info.name,:commit_id=>file_info.repo_commit.id,
      :struct=>file_info.data,:created_at=>file_info.repo_commit.date,:creator=>_creator)
  end

  # 讨论的简介
  def title
    text_node = @nokogiri_struct.css("document text").first
    TextPin.find(:commit_id=>self.commit_id,:repo_user_id=>self.repo_user_id,:repo_name=>self.repo_name, :id=>text_node["id"]).plain_content
  end

  # 这个讨论的所有 text_pin
  def text_pins
    @nokogiri_struct.css("document text").map do |text_node|
      if not_hide?(text_node)
        TextPin.find(:commit_id=>self.commit_id,:repo_user_id=>self.repo_user_id,:repo_name=>self.repo_name, :id=>text_node["id"])
      end
    end.compact
  end

  def not_hide?(node)
    !(!!node['hidden'] && node['hidden']=="true")
  end

  # 讨论内容的树状结构
  # {:root=>[
  #   :text_pin=>text_pin,:children=>[:text_pin=>text_pin,:children=>[]],
  #   :text_pin=>text_pin,:children=>[:text_pin=>text_pin,:children=>[]]
  #   ]
  # }
  def text_pin_tree(observer=nil)
    {:root=>_text_pin_arr(@nokogiri_struct.at_css("document"),observer)}
  end

  def visable?(tn,observer)
    sign = not_hide?(tn)
    if observer
      return sign && self.visible_config.tu_visible_for?(tn['id'],observer)
    end
    sign
  end

  def _text_pin_arr(text_node,observer)
    text_node.xpath("./text").map do |tn|
      if visable?(tn,observer)
        text_pin = TextPin.find(:commit_id=>self.commit_id,:repo_user_id=>self.repo_user_id,:repo_name=>self.repo_name,:id=>tn["id"])
        if observer.blank? || self.visible_config.uu_visible_for?(text_pin.creator,observer)
          {:text_pin=>text_pin, :children=>_text_pin_arr(tn,observer)}
        end
      end
    end.compact
  end

  # 这个讨论的所有参与者
  def joiners
    @nokogiri_struct.css("joiners joiner").map do |joiner_node|
      User.find_by_email(joiner_node["email"])
    end
  end

  def self.init_xml(creator_email,text_pin_id)
    %`
      <document-tree>
        <author email='#{creator_email}'/>
        <joiners>
          <joiner email='#{creator_email}'/>
        </joiners>
        <document>
          <text id='#{text_pin_id}' />
        </document>
      </document-tree>
    `
  end

  # 增加讨论者 到 xml 中
  def add_joiner_to_struct(user)
    if @nokogiri_struct.at_css("joiner[email='#{user.email}']").blank?
      new_joiner = Nokogiri::XML::Node.new('joiner',@nokogiri_struct)
      new_joiner["email"] = "#{user.email}"
      @nokogiri_struct.at_css("joiners").add_child new_joiner
    end
  end

  # 修改 text_pin 的 最后修改时间 到 xml 中
  def update_text_pin_updated_at_to_struct(text_pin_id)
    node = @nokogiri_struct.at_css("text[id='#{text_pin_id}']")
    node["updated_at"] = Time.now.to_s
  end

  # 增加 text_pin 到 xml 中
  def add_text_pin_to_struct(text_pin_id,parent_id)
    if @nokogiri_struct.at_css("text[id='#{text_pin_id}']").blank?
      new_text = Nokogiri::XML::Node.new('text',@nokogiri_struct)
      new_text["id"] = "#{text_pin_id}"
      node = parent_id.blank? ? (@nokogiri_struct.at_css("document")) : (@nokogiri_struct.at_css("text[id='#{parent_id}']"))
      node.add_child new_text
    end
  end

  # 找到document中的某一个text_pin
  def find_text_pin(text_pin_id)
    TextPin.find(:id=>text_pin_id,:repo_user_id=>self.repo_user_id,:repo_name=>self.repo_name)
  end

  # 修改document中的某一个text_pin
  # :text_pin_id=>new_pin.id,:user=>tom,:text_pin=>{:content=>'tom这个小伙子到此一游'}
  def edit_text_pin(options)
    add_joiner_to_struct(options[:user])
    update_text_pin_updated_at_to_struct(options[:text_pin_id])
    document_xml = @nokogiri_struct.to_s

    text_xml = TextPin.init_xml(options[:text_pin])
    params = [
      {:data=>text_xml,:to=>File.join(TextPin::SUB_PATH,options[:text_pin_id])},
      {:data=>document_xml,:to=>File.join(Document::SUB_PATH,self.id)}
    ]
    if commit_files_to_repository(params, options[:user])
      self.add_discussion(options[:user])
      return true
    end
    false
  end

  # 参数  :text_pin_id=>new_pin.id,:user=>tom
  def remove_text_pin(options)
    text_pin_element = @nokogiri_struct.at_css("text[id='#{options[:text_pin_id]}']")
    if !text_pin_element.blank?
      text_pin_element["hidden"] = 'true'
    end
    document_xml = @nokogiri_struct.to_s
    params = [{:data=>document_xml,:to=>File.join(Document::SUB_PATH,self.id)}]
    return commit_files_to_repository(params,options[:user])
  end

  # 把文件提交到版本库中去
  def commit_files_to_repository(data_and_tos,user)
    git_repo.add_files(data_and_tos,user) ? true : false
  end

  # 所有提交的历史记录
  def versions
    gr = git_repo
    gr.commits(sub_path).map{|commit|
      file_info = gr.show_file(commit.id,sub_path)
      Document.build_from_file_info(file_info)
    }
  end

  # 返回配置文件路径
  def visible_config_path
    File.join(VisibleConfig::SUB_PATH,self.id)
  end

  # visible_config
  def visible_config
    return @visible_config if @visible_config
    gr = git_repo
    file_info = gr.show_file('master',visible_config_path)
    @visible_config = VisibleConfig.build_from_file_info(file_info)
  end

  # 某人选择屏蔽某text_pin - 同时也就屏蔽了这个分支
  # 参数 :text_pin_id=>text_pin_id,:user=>user
  def invisible_text_pin(options)
    update_invisible_struct_xml(options) do |struct_xml,new_visible|
      return if struct_xml.css("invisible[tid='#{options[:tid]}'][user='#{options[:user].email}']").size != 0
      new_visible["user"] = options[:user].email
      new_visible["tid"] = options[:tid]
      struct_xml.at_css("texts").add_child new_visible
    end
  end

  # 某人解除对某text_pin
  # 参数 :text_pin_id=>text_pin_id,:user=>user
  def visible_text_pin(options)
    struct_xml = Nokogiri::XML(self.visible_config.struct)
    struct_xml.css("texts invisible[tid='#{options[:tid]}'][user='#{options[:user].email}']").each do |invisible|
      invisible.remove
    end
    params = [{:data=>struct_xml.to_s,:to=>visible_config_path}]
    return commit_files_to_repository(params,options[:user])
  end

  # 某人选择屏蔽某text_pin的作者 - 同时也就屏蔽了这个作者所有text以及下面的分支
  # 参数 :tuser=>repo_lifei,:user=>lucy
  def invisible_text_pin_editor(options)
    update_invisible_struct_xml(options) do |struct_xml,new_visible|
      return if struct_xml.css("invisible[tuser='#{options[:tuser].email}'][user='#{options[:user].email}']").size != 0
      new_visible["user"] = options[:user].email
      new_visible["tuser"] = options[:tuser].email
      struct_xml.at_css("users").add_child new_visible
    end
  end
  
  # 某人选择解除对某text_pin的作者的屏蔽
  # 参数 :tuser=>repo_lifei,:user=>lucy
  def visible_text_pin_editor(options)
    struct_xml = Nokogiri::XML(self.visible_config.struct)
    struct_xml.css("users invisible[tuser='#{options[:tuser].email}'][user='#{options[:user].email}']").each do |invisible|
      invisible.remove
    end
    params = [{:data=>struct_xml.to_s,:to=>visible_config_path}]
    return commit_files_to_repository(params,options[:user])
  end

  def update_invisible_struct_xml(options)
    struct_xml = Nokogiri::XML(self.visible_config.struct)
    new_visible = Nokogiri::XML::Node.new('invisible',struct_xml)
    yield(struct_xml,new_visible)
    params = [{:data=>struct_xml.to_s,:to=>visible_config_path}]
    return commit_files_to_repository(params,options[:user])
  end

  # 话题参与记录
  def add_discussion(participant)
    # 增加 参与者到 工作空间
    workspace = document_tree.workspace
    if workspace.user != participant
      MembershipResource.create(:workspace_id=>workspace.id,:email=>participant.email)
    end
    hash = {:participant_id=>participant.id,:document_tree_id=>document_tree.id}
    discussion = Discussion.find(:first,:conditions=>hash)
    return Discussion.create(hash) if discussion.blank?
    discussion.update_attributes(:hide=>false)
  end

  # 某用户在这个话题中屏蔽的所有text_pins
  def invisible_text_pins_of(user)
    struct_xml = Nokogiri::XML(self.visible_config.struct)
    struct_xml.css("texts invisible[user='#{user.email}']").map do |invisible|
      self.find_text_pin(invisible["tid"])
    end
  end

  # 某个 text_pin 被 那些用户 屏蔽了
  def invisibles_of(text_pin)
    struct_xml = Nokogiri::XML(self.visible_config.struct)
    struct_xml.css("texts invisible[tid='#{text_pin.id}']").map do |invisible|
      User.find_by_email(invisible["user"])
    end
  end

  # 某用户在这个话题中屏蔽的所有人
  def invisible_users_of(user)
    struct_xml = Nokogiri::XML(self.visible_config.struct)
    struct_xml.css("users invisible[user='#{user.email}']").map do |invisible|
      User.find_by_email(invisible["tuser"])
    end
  end

  # 发送邀请邮件
  def invite(user,email)
    return false if joined?(email)
    di = DiscussionInvitation.find(:first,:conditions=>{:email=>email,:document_tree_id=>document_tree.id})
    if di.blank?
      di = DiscussionInvitation.create(:inviter=>user,:email=>email,:document_tree_id=>document_tree.id)
    end
    Mailer.deliver_invite_to_document(di,self)
  end

  # 判断这个邮箱的记录是否已经参与了这个话题
  def joined?(email)
    self.joiners.map{|user_temp|user_temp.email}.include?(email)
  end
end