# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  
  before_filter :fix_ie6_accept
  helper :all
  protect_from_forgery

  # 通过插件开启gzip压缩
  after_filter OutputCompressionFilter

  private
  # 修正IE6浏览器请求头问题
  def fix_ie6_accept
    if /MSIE 6/.match(request.user_agent) && request.env["HTTP_ACCEPT"]!='*/*' && !/.*\.gif/.match(request.url)
      request.env["HTTP_ACCEPT"] = '*/*'
    end
  end

  def is_flash_request?
    !!(request.env['HTTP_USER_AGENT'] =~ /^(Adobe|Shockwave) Flash/)
  end

  def pre_page
    10
  end

  before_filter :init_layout
  around_filter :catch_access_exception
  around_filter :transaction_filter

  protected
  def init_layout
    @mindpin_layout = MindpinLayout.new
  end

  def catch_access_exception
    begin
      yield
    rescue ActionView::MissingTemplate => ex
      if RAILS_ENV=='production'
        render :update do |page|
          page<< %`show_fbox('参数或模板错误');`
        end
      else
        raise ex
      end
    end
  end

  def transaction_filter
    return yield if request.get?
    ActiveRecord::Base.transaction do
      yield
    end
  end

  # 刷新当前页面
  def refresh_local_page
    render_ui {|ui| ui.page << %` window.location.href=window.location.href; `}
  end
  
end