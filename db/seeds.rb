Authorization.ignore_access_control(true)

# 预定义的角色
["Admin", "Teacher", "Student"].each do |name|
  Role.create!(:name => name)
end
p 'roles created.'

# 管理员用户
admin = User.new(:email=>"admin@mindpin.com",:password=>'admin',:password_confirmation=>'admin',
  :name => '系统管理员')
admin.roles << Role.find_by_name('Admin')
if admin.save
  admin.activate
  p 'admin user created.'
end

# 开发环境预置用户
if RAILS_ENV == 'development'
  lifei = User.new(:email=>'fushang318@gmail.com',:password=>'123456',:password_confirmation=>'123456',
    :name => '李飞')
  lifei.roles << Role.find_by_name('Teacher')
  lifei.save!
  lifei.activate

  chengliwen = User.new(:email=>'chinachengliwen@gmail.com',:password=>'123456',:password_confirmation=>'123456',
    :name => '程立文')
  chengliwen.roles << Role.find_by_name('Teacher')
  chengliwen.save!
  chengliwen.activate

  ben7th = User.new(:email=>'ben7th@gmail.com',:password=>'123456',:password_confirmation=>'123456',
    :name => '宋亮')
  ben7th.roles << Role.find_by_name('Teacher')
  ben7th.save!
  ben7th.activate

  liyutong = User.new(:email=>'liyutong@gmail.com',:password=>'123456',:password_confirmation=>'123456',
    :name => '李雨桐')
  liyutong.roles << Role.find_by_name('Student')
  liyutong.save!
  liyutong.activate
end