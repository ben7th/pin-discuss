class RepositoryFileInfo
  # repo_commit name path kind size mime_type data
  attr_reader :repo_commit,:name,:path,:kind,:size,:mime_type,:data,:repo
  def initialize(info)
    @attrs = info
    @attrs.each do |name,value|
      self.instance_variable_set("@#{name}", value)
    end
  end


  # RepositoryFileInfo.build(:repo_commit=>repo_commit,:item=>file_blob,:path=>file_name)
  # repo_commit name path kind size mime_type data
  def self.build(hash)
    # 构建提交相关信息
    repo_commit = hash[:repo_commit]
    repo = hash[:repo]
    # 构建 文件或目录的相关信息
    item = hash[:item]
    name = item.name
    path = hash[:path].gsub(/^(\.\/)/,"")
    kind = item.class.to_s.sub("Grit::","").downcase
    size = 0
    mime_type = "tree"
    data = ""
    if item.instance_of?(Grit::Blob)
      size = item.size
      mime_type = item.mime_type
      data = item.data
    end
    self.new(:repo=>repo,:repo_commit=>repo_commit,:name=>name,:path=>path,:kind=>kind,:size=>size,:mime_type=>mime_type,:data=>data)
  end

end