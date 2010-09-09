module GitRepositoryHelper
  # 按照日期 将提交进行分类
  def commits_group_by_datetime(repository_commits)
    repository_commits_by_date = {}
    repository_commits.each do |repository_commit|
      time = year_month_and_day(repository_commit.date)
      if !repository_commits_by_date.has_key?(time)
        repository_commits_by_date.merge!(time=>[repository_commit])
        next
      end
      repository_commits_by_date[time] << repository_commit
    end
    repository_commits_by_date.sort{|a,b| DateTime.parse(b[0])<=>DateTime.parse(a[0])}
  end

  # 将文件修改的内容显示
  def diff_texts(text)
    lines = text.split(/\r?\n/)
    head_message = lines[0..2]
    str = %`<div class='diff_message'>#{head_message*' '}</div><div class='text_content'>`
    (lines[3..lines.size] || []).each do |line|
      lin_content = line.gsub(/^[\-\+]/,"")
      case true
      when !!line.match(/^\-/) then str << %`<div class='diff_sub'>#{lin_content}</div>`
      when !!line.match(/^\+/) then str << %`<div class='diff_add'>#{lin_content}</div>`
      else str << %`<div class='diff_no_changed'>#{line}</div>`
      end
    end
    str << "</div>"
  end

  def diff_images(diff)
    last_commit_id = diff.last_commit_id
    new_commit_id = diff.new_commit_id
    image_new_src = raw_repo_file_path(:commit_id=>new_commit_id,:path=>diff.new_name)
    html_str = %`<image src='#{image_new_src}' />`
    if !last_commit_id.blank?
      image_old_src = raw_repo_file_path(:commit_id=>last_commit_id,:path=>diff.last_name)
      html_str << %`<image src='#{image_old_src}' />`
    end
    html_str
  end
  
end
