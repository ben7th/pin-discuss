class RepositoriesController < ApplicationController

  before_filter :per_load
  def per_load
    @repository = Repository.find(params[:id]) if params[:id]
  end

  def index
    user = User.find params[:user_id]
    @repositories = user.repositories
  end

  def new
    render_ui do |ui|
      ui.fbox :show,:title=>"创建版本库",:partial=>"repositories/new"
    end
  end

  def create
    render_ui do |ui|
      repo = Repository.new(:user=>current_user,:name=>params[:repo_name])
      if repo.save
        ui.fbox :close
        ui.mplist :insert,repo,:partial=>"/repositories/info_repository",:locals=>{:user_id=>current_user.id,:repository=>repo}
      else
        flash.now[:error] = "名称已存在"
        ui.fbox :show,:title=>"创建版本库",:partial=>"repositories/new"
      end
    end
  end

  def edit
    render_ui do |ui|
      ui.fbox :show,:title=>"修改",:partial=>"/repositories/edit",:locals=>{:repository=>@repository,:user_id=>params[:user_id]}
    end
  end

  def update
    if @repository.update_attributes(:name=>params[:new_repo_name])
      refresh_local_page
    end
  end

  def show_root
    @commit_id = "master"
    @repository_file_infos = GitRepository.find(params[:user_id],params[:repo_name]).show(@commit_id,"")
  end

  def show_directory
    @commit_id = params[:commit_id]
    path = File.join(params[:path])
    @repository_file_infos = GitRepository.find(params[:user_id],params[:repo_name]).show(@commit_id,path)
  end

  def add_file_form
    render_ui do |ui|
      ui.fbox :show,:title=>"添加文件",:partial=>"/repositories/add_file_form"
    end
  end

  def commit
    repo_name = params[:repo_name]
    file_path = params[:file].path

    if GitRepository.find(current_user.id,params[:repo_name]).add_files([{:from=>file_path,:to=>params[:file].original_filename}],current_user)
      return redirect_to :action=>:show_root,:repo_name=>repo_name,:user_id=>current_user.id
    end
    render :action=>:add_file_form
  end

  def _file_info
    user_id,repo_name,commit_id,path = params[:user_id],params[:repo_name],params[:commit_id],params[:path]
    file_path = File.join(path)
    @repo_file_info = GitRepository.find(user_id,repo_name).show_file(commit_id,file_path)
  end

  def show_file
    _file_info
  end

  def raw_file
    _file_info
    send_data @repo_file_info.data, :filename => @repo_file_info.name,:type => @repo_file_info.mime_type, :disposition => 'inline'
  end

  def commits
    repo_name = params[:repo_name]
    user_id = params[:user_id]

    all_path_arr = params[:path]
    file_path = File.join(all_path_arr)
    @commits = GitRepository.find(user_id,repo_name).commits(file_path)
  end

  def reupload_repo_file
    render_ui do |ui|
      ui.fbox :show,:title=>"重新上传文件",:partial=>"/repositories/parts/form_reupload_file"
    end
  end

  def edit_repo_file
    file_content_text = GitRepository.find(params[:user_id],params[:repo_name]).show_file("master",File.join(params[:path])).data
    render_ui do |ui|
      ui.page << %`
        $$('.text_content').each(function(text_content){text_content.addClassName("hide");});
        $$('.file_content').each(function(file_content){
          file_content.insert(#{@template.render(:partial=>"/repositories/parts/form_edit_text_file",:locals=>{:file_content_text=>file_content_text}).to_json},{position:'bottom'});
        });
      `
    end
  end

  def change_repo_file
    file = params[:file]
    if params[:text]
      file = Tempfile.new(randstr)
      file << params[:text]
      file.close
    end
    GitRepository.find(params[:user_id],params[:repo_name]).add_files([{:from=>file.path,:to=>File.join(params[:path])}],current_user)
    return refresh_local_page if params[:text]
    responds_to_parent{refresh_local_page}
  end

  def show_commit
    @diffs = GitRepository.find(params[:user_id],params[:repo_name]).commit_diffs(params[:commit_id])
  end 

end