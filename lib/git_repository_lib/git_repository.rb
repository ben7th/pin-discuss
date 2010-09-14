class GitRepository

  # 找到某个版本库
  def self.find(user_id,repo_name)
    path = self.repository_path(user_id,repo_name)
    return nil if !File.exist?(path)
    gr = GitRepository.new(:user_id=>user_id,:repo_name=>repo_name)
    gr.instance_variable_set(:@is_find, true)
    gr
  end

  # 删除一个版本库
  # 其实是把该版本库 放入 回收站 目录
  def destroy
    return false if !File.exist?(path)
    recycle_path = GitRepository.user_recycle_path(@user.id)
    run_cmd "mv #{path} #{recycle_path}/#{@name}_#{randstr}"
    return true
  end

  # 删除版本库里的某个文件
  def delete_file(file_path)
    return false if file_path.blank?
    absolute_file_path = File.join(path,file_path)
    return false if !File.exist?(absolute_file_path)
    @repo.remove(file_path)
    @repo.commit("remove file #{file_path}")
    return true
  end

  def commits(path)
    @repo.log("master",path).map do |commit|
      GitRepository.bulid_commit(commit)
    end
  end
  
  # 根据 commit_id 获得 对应的 RepositoryCommit
  def commit(commit_id)
    GitRepository.bulid_commit(@repo.commits(commit_id).first)
  end
  
  # 把 Grit::Commit 转换成 RepositoryCommit
  def self.bulid_commit(grit_commit)
    RepositoryCommit.new({
        :message=>grit_commit.message,:date=>grit_commit.date,:grit_commit=>grit_commit,
        :author=>grit_commit.author.name,:email=>grit_commit.author.email,:id=>grit_commit.id
      })
  end

  # 找到用户的所有版本库
  def self.find_all(user_id)
    self.init_user_path(User.find(user_id))
    user_git = GitRepository.user_repository_path(user_id)
    repositories = []
    Dir.foreach(user_git) do |file_item|
      begin
        if file_item!="."&&file_item!=".."
          repo = self.find(user_id,file_item)
          repositories << repo
        end
      rescue Grit::InvalidGitRepositoryError => ex
        p ex
        next
      end
    end
    repositories
  end

  # 获得 commit_id 提交的版本中 sub_path 的 目录树快照
  def _item(commit_id,sub_path)
    sub_path = "/" if ["/","./",".",""].include?(sub_path)
    repo_commit = @repo.commit(commit_id)
    return nil if repo_commit.nil?
    sub_path.gsub!(/^(\.?\/?)/,"") if sub_path != "/"
    repo_commit.tree./(sub_path)
  end

  # 获得 commit_id 提交的版本中 file_path 对应的文件的最新提交日志
  def _first_log(commit_id,file_path)
    file_path.gsub!(/^\//,"./")
    @repo.log(commit_id,file_path).first
  end

  # 根路径 sub_path = ""
  def show(commit_id,sub_path)
    repository_files = []
    tree = _item(commit_id,sub_path)
    return repository_files if tree.nil?
    
    raise "sub_path #{sub_path} 不是一个有效的目录" if !tree.instance_of?(Grit::Tree)
    tree.contents.each do |item|
      file_path = File.join(sub_path,item.name)
      commit = _first_log(commit_id,file_path)
      repo_commit = GitRepository.bulid_commit(commit)
      repository_files << RepositoryFileInfo.build(:repo=>self,:repo_commit=>repo_commit,:item=>item,:path=>file_path)
    end
    repository_files
  end

  def show_file(commit_id,file_name)
    file_blob = _item(commit_id,file_name)
    raise "file_name #{file_name} 不是一个有效的文件" if !file_blob.instance_of?(Grit::Blob)
    commit = @repo.log(commit_id,file_name).first
    repo_commit = GitRepository.bulid_commit(commit)
    return RepositoryFileInfo.build(:repo=>self,:repo_commit=>repo_commit,:item=>file_blob,:path=>file_name)
  end

  def add_file_from_metal(file,sub_path)
    file_path = file[:tempfile].path
    file_name = file[:filename]
    repo_file_path = File.join(".",sub_path,file_name)
    add_file(file_path,file_name,repo_file_path)
  end

  # 增加文件
  # add_files([{:from=>"/tmp/hello",:to=>"nihao"}],email,:message=>"add some file")
  def add_files(from_and_to_arr,email,options = {})
    user = User.find_by_email(email)
    name = user.blank? ? email : user.name
    
    @repo.config['user.name'] = name
    @repo.config['user.email'] = email

    from_and_to_arr.each do |from_and_to|
      file_path = from_and_to[:from]
      file_data = from_and_to[:data]
      repo_file_path = from_and_to[:to]
      
      if file_path.blank?
        temp_file = Tempfile.new(randstr)
        temp_file << file_data
        temp_file.close
        _add_file_to_repo(temp_file.path,repo_file_path)
        temp_file.delete
      else
        _add_file_to_repo(file_path,repo_file_path)
      end
    end

    message = options[:message] || "##"
    @repo.commit_index(message)
    return true
  end

  def _add_file_to_repo(file_path,repo_file_path)
    sub_path = File.dirname(repo_file_path)

    absolute_prefix_path = File.join(path,sub_path)
    FileUtils.mkdir_p(absolute_prefix_path)

    absolute_file_path = File.join(path,repo_file_path)
    FileUtils.cp_r(file_path,absolute_file_path)

    @repo.add(repo_file_path)
  end

  def checkout(file_path)
    Dir.chdir(path) do
      @repo.git.checkout({},file_path)
    end
  end

  def reset_hard
    Dir.chdir(path) do
      @repo.git.reset({:hard=>true})
    end
  end

  def commit_diffs(commit_id)
    commit_first = @repo.commits(commit_id).first
    commit_first.diffs.map{|diff|RepositoryDiff.build_from_diff(diff,commit_first)}
  end

  # 重命名repo
  def rename(new_name)
    run_cmd "mv #{path} #{GitRepository.user_repository_path(@user.id)}/#{new_name}"
  end

  include GitRepositoryMethods
end