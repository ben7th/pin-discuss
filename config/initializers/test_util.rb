class ActiveSupport::TestCase
  def retest(str)
    eval("test_#{str}")
  end

  # 清空指定模型对应的数据库表
  # 不建议使用，因为可能影响到有缓存的场合
  def clear_model(*args)
    warn "[警告] clear_model in ActiveSupport::TestCase 方法不建议使用，因为可能影响到有缓存的场合"
    without_access_control do
      args.each do |clazz|
        clazz.all.each do |m|
          clazz.expire_caches m
          m.delete
        end
      end
    end
  end
end

class ActionController::IntegrationTest
  # 集成测试中的用户登录
  def login(user,password='123456')
    post "/session", :email => user.email, :password => password
    assert_equal session[:user_id] , user.id
    return user
  end

  # 集成测试中的用户登出
  def logout
    get "/logout"
  end

end
