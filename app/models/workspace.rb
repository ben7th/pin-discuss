class Workspace < ActiveRecord::Base
  set_readonly(true)
  build_database_connection("pin-workspace")
  belongs_to :user
  has_many :discussions


  # 在这个工作空间下创建一个讨论
  # options = {:email=>email,:text_pin=>{:content=>@email["body"],:format=>""}}
  def create_document(options)
    repo_user_id = self.user_id
    repo_name = self.id
    options = options.merge({:repo_user_id=>repo_user_id,:repo_name=>repo_name})
    DocumentSyncMail.create(options)
  end

  def mail_address
    "workspaces_#{id}@mindpin.com"
  end

  if RAILS_ENV=="test" && !self.table_exists?
    self.connection.create_table :workspaces do |t|
      t.string :name
      t.integer :user_id
      t.timestamps
    end
  end

  module UserMethods
    def self.included(base)
      base.has_many :workspaces
    end
  end


  ###########
  has_many :memberships
  has_many :apply_memberships,:conditions=>["memberships.status = ?",Membership::APPLY],:class_name=>"Membership"
  has_many :joined_memberships,:conditions=>["memberships.status = ?",Membership::JOINED],:class_name=>"Membership"
  has_many :baned_memberships,:conditions=>["memberships.status = ?",Membership::BANED],:class_name=>"Membership"

  def apply_member_emails
    self.apply_memberships.map{|ms| ms.email}
  end

  def member_emails
    self.joined_memberships.map{|ms| ms.email}
  end

  def baned_member_emails
    self.baned_memberships.map{|ms| ms.email}
  end
  #############
  
end
