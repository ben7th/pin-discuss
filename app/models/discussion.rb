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
    total = discussion_log_infos.count.to_f
    statistic_hash = {}
    
    discussion_log_infos.each do |info|
      if statistic_hash[info.email].blank?
        statistic_hash[info.email] = 1
      else
        statistic_hash[info.email] += 1
      end
    end
    statistic_hash.each{|key,value| statistic_hash[key] = to_baifen(value/total)}
  end
  
  def to_baifen(num)
    sprintf("%.2f%",num*100)
  end


end
