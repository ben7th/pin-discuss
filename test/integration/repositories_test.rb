require 'test_helper'

class RepositoriesTest < ActionController::IntegrationTest
  fixtures :all

  test "看一个文件的提交记录" do
    lifei = users(:repo_lifei)
    repo_test_path = "#{GitRepository.user_repository_path(lifei.id)}/repo_test"
    FileUtils.rm_rf(repo_test_path)
    FileUtils.cp_r("#{RAILS_ROOT}/test/upload_files/repo_test",repo_test_path)
    get "users/#{lifei.id}/repositories/repo_test/commits/master/1.txt"
    assert_equal assigns(:commits).count,2
  end

  test "删除一个版本库" do
    user = get_user
    clear_user_repositories(user)

    repo_name = "lifei_test_repo"
    create_repository(user,repo_name)

    GitRepository.find(user.id,repo_name).destroy
    assert !File.exist?(GitRepository.repository_path(user.id,repo_name))

    assert_equal nil,GitRepository.find(user.id,repo_name)
  end

  test "给一个版本库改名" do
    user = get_user
    clear_user_repositories(user)

    repo_name = "lifei_test_repo"
    create_repository(user,repo_name)

    GitRepository.find(user.id,repo_name).rename("new_repo")
    assert !File.exist?(GitRepository.repository_path(user.id,repo_name))
    assert File.exist?(GitRepository.repository_path(user.id,"new_repo"))
  end

  test "在版本库里增加一个文件" do
    user = get_user
    clear_user_repositories(user)

    repo_name = "lifei_test_repo"
    create_repository(user,repo_name)
    file_path = "#{RAILS_ROOT}/test/upload_files/test.txt"
    sub_path = ""
    add_file_to_repository(user,repo_name,sub_path,file_path)

    sub_path = "hello/nihao"
    add_file_to_repository(user,repo_name,sub_path,file_path)
  end

  test "在版本库里删除一个文件" do
    user = get_user
    clear_user_repositories(user)

    repo_name = "lifei_test_repo"
    create_repository(user,repo_name)
    file_path = "#{RAILS_ROOT}/test/upload_files/test.txt"
    sub_path = "hello/nihao"
    add_file_to_repository(user,repo_name,sub_path,file_path)

    file_name = File.basename(file_path)
    repo_file_path = File.join(sub_path,file_name)

    GitRepository.find(user.id,repo_name).delete_file(repo_file_path)
    assert !File.exist?("#{GitRepository.repository_path(user.id,repo_name)}/#{sub_path}/#{file_name}")
  end

  # 增加文件资源
  def add_file_to_repository(user,repo_name,sub_path,file_path)
    file_name = File.basename(file_path)
    assert !File.exist?("#{GitRepository.repository_path(user.id,repo_name)}/#{sub_path}/#{file_name}")
    repo_file_path = File.join(sub_path,file_name)
    GitRepository.find(user.id,repo_name).add_files([{:from=>file_path,:to=>repo_file_path}],user.email)
    assert File.exist?("#{GitRepository.repository_path(user.id,repo_name)}/#{sub_path}/#{file_name}")
  end

  def create_repository(user,repo_name)
    assert !File.exist?(GitRepository.repository_path(user.id,repo_name))
    GitRepository.create(:user=>user,:repo_name=>repo_name)
    assert File.exist?(GitRepository.repository_path( user.id,repo_name))
  end

  def get_user
    users(:repo_lifei)
  end

  def clear_user_repositories(user)
    FileUtils.rm_rf(GitRepository.user_repository_path(user.id))
  end
end