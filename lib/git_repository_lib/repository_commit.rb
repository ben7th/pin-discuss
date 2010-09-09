class RepositoryCommit
  attr_reader :message,:date,:author,:email,:id,:grit_commit
  def initialize(info)
    @id = info[:id] || info["id"]
    @message = info[:message] || info["message"]
    @date = info[:date] || info["date"]
    @author = info[:author] || info["author"]
    @email = info[:email] || info["email"]
    @grit_commit = info[:grit_commit] || info['grit_commit']
  end

end