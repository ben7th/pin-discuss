
ActionController::Routing::Routes.draw do |map|
  
  #----------------git 服务（暂时没有使用）-------------------
  map.repo_index "/users/:user_id/repositories",:controller=>"repositories",:action=>"index",:conditions=>{:method=>:get}
  map.create_repo "/users/:user_id/repositories",:controller=>"repositories",:action=>"create",:conditions=>{:method=>:post}
  map.new_repo "/users/:user_id/repositories/new",:controller=>"repositories",:action=>"new",:conditions=>{:method=>:get}
  map.commit_repo "/users/:user_id/repositories/:repo_name",:controller=>"repositories",:action=>"commit",:conditions=>{:method=>:post}
  # 修改一个版本库的名字
  map.edit_repo "/users/:user_id/repositories/:id/edit",:controller=>"repositories",:action=>"edit",:conditions=>{:method=>:get}
  map.update_repo "/users/:user_id/repositories/:id",:controller=>"repositories",:action=>"update",:conditions=>{:method=>:put}

  map.add_repo_file "/users/:user_id/repositories/:repo_name/add_file_form",:controller=>"repositories",:action=>"add_file_form",:conditions=>{:method=>:get}
  # 显示一个版本库的根目录
  map.show_repo_root "/users/:user_id/repositories/:repo_name",:controller=>"repositories",:action=>"show_root",:conditions=>{:method=>:get}
  # 显示一个版本库的子目录
  map.show_repo_directory "/users/:user_id/repositories/:repo_name/tree/:commit_id/*path",:controller=>"repositories",:action=>"show_directory",:conditions=>{:method=>:get}
  # 一个文件的显示页面
  map.show_repo_file "/users/:user_id/repositories/:repo_name/blob/:commit_id/*path",:controller=>"repositories",:action=>"show_file",:conditions=>{:method=>:get}
  # 文件的raw地址（下载地址）
  map.raw_repo_file "/users/:user_id/repositories/:repo_name/raw/:commit_id/*path",:controller=>"repositories",:action=>"raw_file",:conditions=>{:method=>:get}
  # 文件的历史记录
  map.repo_commits "/users/:user_id/repositories/:repo_name/commits/master/*path",:controller=>"repositories",:action=>"commits",:conditions=>{:method=>:get}
  # 重新上传，或文本的编辑修改
  map.change_repo_file "/users/:user_id/repositories/:repo_name/*path",:controller=>"repositories",:action=>"change_repo_file",:conditions=>{:method=>:put}
  # 编辑表单
  map.edit_repo_file "/users/:user_id/repositories/:repo_name/edit/*path",:controller=>"repositories",:action=>"edit_repo_file",:conditions=>{:method=>:get}
  # 重新上传表单
  map.reupload_repo_file "/users/:user_id/repositories/:repo_name/reupload/*path",:controller=>"repositories",:action=>"reupload_repo_file",:conditions=>{:method=>:get}
  # 查看提交信息
  map.show_commit "users/:user_id/repositories/:repo_name/commit/:commit_id",:controller=>"repositories",:action=>"show_commit",:conditions=>{:method=>:get}

  #-----------------------文本资源---------------------#
  #  map.resources :text_pins
  map.resources :documents, :path_prefix => '/workspaces/:workspace_id',
    :member=>{:invisible_tu=>:put,:invisible_uu=>:put,:visible_tu=>:put,:visible_uu=>:put,
    :reply_form=>:get,:reply=>:post,:raw=>:get,:invite_form=>:get,:invite=>:post,:oprations_statistic=>:get} do |document|
    document.resources :text_pins,:member=>{:raw=>:get,:convert_mindmap=>:post}
  end
  map.add_on_create_discussion "/add_on_create_discussion",:controller=>"documents",:action=>"add_on_create",:conditions=>{:method=>:post}

  map.mindmap_to_bundle "/documents/mindmaps",:controller=>"mindmaps",:action=>"create",:conditions=>{:method=>:post}
  #--------------------
  map.resources :discussion_participants
  map.resources :discussion_invitations,:member=>{:registe=>:post,:direct_login=>:get}


end