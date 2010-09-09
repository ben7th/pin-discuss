class Membership < ActiveRecord::Base
  set_readonly(true)
  build_database_connection("pin-workspace")
  belongs_to :workspace

  JOINED  = "JOINED"    # 正式成员
  APPLY   = "APPLY"     # 申请加入
  REFUSED = "REFUSED"   # 申请加入被拒绝
  QUIT    = "QUIT"      # 退出
  INVITE  = "INVITE"    # 邀请
  BANED  = "BANED"    # 禁止了，加入了黑名单

  if RAILS_ENV=="test" && !self.table_exists?
    self.connection.create_table :memberships do |t|
      t.integer :workspace_id
      t.string :email
      t.string :status
      t.timestamps
    end
  end
end
