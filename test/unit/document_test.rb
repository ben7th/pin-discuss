require 'test_helper'

class DocumentTest < ActiveSupport::TestCase

  def document_test
    repo_lifei = users(:repo_lifei)
    repo_name = "repo_first"
    clear_user_repositories(repo_lifei)
    workspace = create_workspace(repo_lifei,repo_name)
    yield(repo_lifei,workspace.id)
    clear_user_repositories(repo_lifei)
  end

  test "创建讨论,回复讨论" do
    document_test do |repo_lifei,repo_name|
      lucy = users(:lucy)
      content = "关于XX的讨论"
      text_pin = {:content=>content,:format=>""}
      document = nil
      assert_difference(["DiscussionParticipant.count","Discussion.count"],1) do
        document = DocumentSyncMail.create(:repo_name=>repo_name,:repo_user_id=>repo_lifei.id,:email=>repo_lifei.email,:text_pin=>text_pin)
      end
      discussion_participant = DiscussionParticipant.last
      discussion = Discussion.last
      assert_equal discussion_participant.discussion,discussion
      assert_equal discussion_participant.email,repo_lifei.email
      assert_equal discussion.workspace.user,repo_lifei
      assert_equal discussion.workspace.id,repo_name

      assert_equal document.email,repo_lifei.email
      assert_equal document.joiner_emails.size,1
      assert document.joiner_emails.include?(repo_lifei.email)
    
      assert_equal document.text_pins.size,1
      text_pin = document.text_pins[0]
      assert_equal text_pin.email,repo_lifei.email
      assert_equal text_pin.struct,TextPin.init_xml({:content=>content})
      # 判断 配置文件 是否存在
      assert File.exist?(File.join(document.git_repo.path,VisibleConfig::SUB_PATH,document.id))
    
      # 回复讨论
      reply_content = "lucy 的观点"
      reply_text_pin = {:content=>reply_content,:format=>""}

      assert_difference("DiscussionParticipant.count",1) do
        DocumentSyncMail.reply(document,:text_pin_id=>text_pin.id,:email=>lucy.email,:text_pin=>reply_text_pin)
      end

      dp_reply = DiscussionParticipant.last
      assert_equal dp_reply.email,lucy.email
      assert_equal dp_reply.discussion,discussion

      document = document.reload
      assert_equal document.joiner_emails.size,2
      assert document.joiner_emails.include?(repo_lifei.email)
      assert document.joiner_emails.include?(lucy.email)
      assert_equal document.text_pins.size,2
      text_pins = document.text_pins
      text_pins.delete_if{|tp| tp.id == text_pin.id}
      assert_equal text_pins.size,1
      new_pin = text_pins[0]
      assert_equal new_pin.email,lucy.email
      assert_equal new_pin.struct,TextPin.init_xml({:content=>reply_content})

      # 编辑讨论
      tom = users(:tom)
      other_text_pin = {:content=>'tom这个小伙子到此一游',:format=>""}
      assert_difference("DiscussionParticipant.count",1) do
        document.edit_text_pin(:text_pin_id=>new_pin.id,:email=>tom.email,:text_pin=>other_text_pin)
      end
      document_changed = document.reload

      dp_edit = DiscussionParticipant.last
      assert_equal dp_edit.email,tom.email
      assert_equal dp_edit.discussion,discussion

      assert_equal document_changed.joiner_emails.size,3
      assert document_changed.joiner_emails.include?(tom.email)
      assert_equal document_changed.text_pins.size,2
      text_pin_changed = document_changed.find_text_pin(new_pin.id)
      assert_equal text_pin_changed.plain_content,"tom这个小伙子到此一游"
      assert_equal text_pin_changed.email,tom.email

      # tom再次编辑了而这个文本，不应该重复创建一条discussion
      assert_difference("DiscussionParticipant.count",0) do
        document.edit_text_pin(:text_pin_id=>new_pin.id,:email=>tom.email,:text_pin=>other_text_pin)
      end

      # 修改之后的text_pin 有两个版本啦
      versions = text_pin_changed.versions
      assert_equal versions.size,2
      assert_not_equal versions[0].struct,versions[1].struct

      # 有一个用户要删除其中的一个分支
      document.remove_text_pin(:text_pin_id=>new_pin.id,:email=>tom.email)
      document_changed_again = document.reload
      assert_equal document_changed_again.text_pins.size,1
      assert_equal document_changed_again.joiner_emails.size,3
      assert_equal document_changed_again.text_pin_tree[:root].size,1

    end
  end

  test "在参数不全的情况下，试图创建一个讨论" do
    document_test do |repo_lifei,repo_name|
      content = "关于XX的讨论"
      text_pin = {:content=>content,:format=>""}
      options_1 = {:repo_name=>repo_name,:creator=>repo_lifei}
      options_2 = {:creator=>repo_lifei,:text_pin=>text_pin}
      options_3 = {:text_pin=>text_pin}

      assert !Document.create_valid?(options_1)
      assert !Document.create_valid?(options_2)
      assert !Document.create_valid?(options_3)

      document = DocumentSyncMail.create(options_1)
      assert_equal false,document
    end
  end

  test "测试text_pin 的文本格式和内容的拼装" do
    document_test do |repo_lifei,repo_name|
      content = %`今天天气<很因涔涔的\n凌晨的时候刚>刚下过雨
      `
      format = [{:type=>"bold",:from=>"1.1",:to=>"1.5"},{:type=>"italic",:from=>"1.2",:to=>"2.5"}]
      text_pin = {:content=>content,:format=>format}
      document = DocumentSyncMail.create(:repo_name=>repo_name,:repo_user_id=>repo_lifei.id,:email=>repo_lifei.email,
        :text_pin=>text_pin)
      text_pin = document.text_pins[0]
      xml_content = Nokogiri::XML(text_pin.struct)
      bold = xml_content.css("format").css('bold')[0]
      assert_equal bold['from'],'1.1'
      assert_equal bold['to'],'1.5'
      bold = xml_content.css("format").css('italic')[0]
      assert_equal bold['from'],'1.2'
      assert_equal bold['to'],'2.5'
    end
  end

  test "屏蔽某文本,然后解除屏蔽这个文本" do
    document_test do |repo_lifei,repo_name|
      lucy = users(:lucy)
      tpin = {:content=>"关于XX的讨论",:format=>""}
      document = DocumentSyncMail.create(:repo_name=>repo_name,:repo_user_id=>repo_lifei.id,:email=>repo_lifei.email,:text_pin=>tpin)
      text_pin = document.text_pins[0]
      document.invisible_text_pin(:tid=>text_pin.id,:email=>lucy.email)
      document = document.reload
      visible_xml = document.visible_config.struct
      texts_invisibles = Nokogiri::XML(visible_xml).css("texts invisible")
      assert_equal texts_invisibles.size,1
      assert_equal texts_invisibles[0]['tid'],text_pin.id
      assert_equal texts_invisibles[0]['user'],lucy.email
      
      assert_equal document.visible_config.tu_visible_for?(text_pin.id,lucy.email),false
      assert_equal document.visible_config.tu_visible_for?(text_pin.id,repo_lifei.email),true

      # 重复屏蔽时
      document.invisible_text_pin(:tid=>text_pin.id,:email=>lucy.email)
      document = document.reload
      visible_xml = document.visible_config.struct
      texts_invisibles = Nokogiri::XML(visible_xml).css("texts invisible")
      assert_equal texts_invisibles.size,1

      # 对这个文本 实施 解除屏蔽
      document.visible_text_pin(:tid=>text_pin.id,:email=>lucy.email)
      document = document.reload
      visible_xml = document.visible_config.struct
      texts_invisibles = Nokogiri::XML(visible_xml).css("texts invisible")
      assert_equal texts_invisibles.size,0
    end
  end

  test "屏蔽某人 和 解除对某人的屏蔽" do
    document_test do |repo_lifei,repo_name|
      tom, lucy = users(:tom), users(:lucy)
      tpin = {:content=>"关于XX的讨论",:format=>""}
      document = DocumentSyncMail.create(:repo_name=>repo_name,:repo_user_id=>repo_lifei.id,:email=>repo_lifei.email,:text_pin=>tpin)
      # 屏蔽lucy同学的发言
      document.invisible_text_pin_editor(:temail=>repo_lifei.email,:email=>lucy.email)
      document = document.reload
      text_pin = document.text_pins[0]
      visible_xml = document.visible_config.struct
      users_invisibles = Nokogiri::XML(visible_xml).css("users invisible")
      assert_equal users_invisibles.size,1
      assert_equal users_invisibles[0]['tuser'],text_pin.email
      assert_equal users_invisibles[0]['user'],lucy.email

      assert_equal document.visible_config.uu_visible_for?(repo_lifei.email,lucy.email),false
      assert_equal document.visible_config.uu_visible_for?(repo_lifei.email,tom.email),true

      # 对lucy同学 实施解除屏蔽
      document.visible_text_pin_editor(:temail=>repo_lifei.email,:email=>lucy.email)
      document = document.reload
      text_pin = document.text_pins[0]
      visible_xml = document.visible_config.struct
      users_invisibles = Nokogiri::XML(visible_xml).css("users invisible")
      assert_equal users_invisibles.size,0
    end
  end

  def create_workspace(user,repo_name)
    workspace = Workspace.create(:user=>user,:name=>repo_name)
    GitRepository.create(:user=>user,:repo_name=>workspace.id)
    assert File.exist?(GitRepository.repository_path( user.id,workspace.id))
    return workspace
  end

  def clear_user_repositories(user)
    FileUtils.rm_rf(GitRepository.user_repository_path(user.id))
  end
end
