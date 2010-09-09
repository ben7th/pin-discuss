class IndexController < ApplicationController
  def index
    if !logged_in?
      return render :layout=>'black_index',:template=>'index/login_index'
    end
    respond_to do |format|
      format.html do
        flash[:notice] = '欢迎来访'
        redirect_to '/welcome'
      end
    end
  end

  def updating
   redirect_to '/updating.html',:status=>301
  end

  def dev
    response.charset = "Auto"
    render :text=>'不错啊'
  end

  def updating
    redirect_to '/updating.html',:status=>301
  end

  def v09
    render :layout=>'black_page'
  end

  def v09_up
    # 用户升级，将本身的字段v09_up改为true，然后安装mind_pin 应用，并设置为默认为默认应用
    if !params[:update_item]
      return redirect_to "/" if !current_user.is_v09?
      @update_items = ["update_data","send_email"]
      @update_items << "set_app" if params[:install_mindmap]
      return render :layout=>'black_page'
    end
    return _update_data if params[:update_item] == "update_data"
    return _send_email if params[:update_item] == "send_email"
    return _set_app if params[:update_item] == "set_app"
  end

  def _update_data
    current_user.update_attribute(:v09_up,true)
    Achievement.find_or_create_by_user_id_and_honor(current_user.id,Achievement::V09_USER)
    render :update do |page|end
  end

  def _send_email
    Mailer.deliver_send_upgrade_v09(current_user)
    render :update do |page|end
  end

  def _set_app
    app = App.find_by_name(App::MINDMAP_EDITOR)
    if app
      install = Installing.find_by_user_id_and_app_id(current_user.id,app.id)
      install.destroy if install
      Installing.create(:user=>current_user,:app=>app,:is_default=>true,:usually_used=>true)
    end
    render :update do |page|end
  end

  def welcome
    if !logged_in?
      redirect_to '/'
    end
  end
end
