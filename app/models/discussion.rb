class Discussion < ActiveRecord::Base

  has_many :discussion_invitations
  belongs_to :workspace

  validates_presence_of :workspace_id
  
  def document
    Document.find(:repo_user_id=>self.workspace.user_id,:repo_name=>self.workspace.id,:id=>self.id.to_s)
  end

  # 话题贡献度
  def oprations_statistic
    discussion_log_infos = DiscussionLogParse.new(self.workspace).discussion_log_infos(self.id)
    handle_log_info(discussion_log_infos){|info|info.email}
  end
  
  # 某人在话题中的操作比例
  def oprations_statistic_of(email)
    discussion_log_infos = DiscussionLogParse.new(self.workspace).discussion_log_infos(self.id,[email])
    handle_log_info(discussion_log_infos){|info|get_proxy_value(info)}
  end

  def get_proxy_value(info)
    case info.operate
    when 'create' then "发帖"
    when 'reply' then "发帖"
    when 'delete'then "删除"
    when 'edit' then "编辑"
    end
  end

  def handle_log_info(discussion_log_infos)
    total = discussion_log_infos.count.to_f
    statistic_hash = {}
    discussion_log_infos.each do |info|
      proxy = yield info
      if statistic_hash[proxy].blank?
        statistic_hash[proxy] = {:count=>1}
      else
        statistic_hash[proxy][:count] += 1
      end
    end
    statistic_hash.each{|key,value| statistic_hash[key][:percent] = (value[:count]/total*100)}
  end

end
