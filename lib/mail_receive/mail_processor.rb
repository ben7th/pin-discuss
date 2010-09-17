require 'rubygems'
require 'beanstalk-client'

if ["development","test","production",nil].include?(ARGV[0])
  RAILS_ENV = (ARGV[0] || "production")
end

require File.join(File.dirname(__FILE__), '../..', 'config', 'environment') if !defined?(RAILS_ROOT)


beanstalk = Beanstalk::Pool.new("127.0.0.1:11301")
@logger = Logger.new("#{RAILS_ROOT}/log/queue.log")
@logger.level = Logger::INFO

def process_email(job_hash)
  @logger.info("传进来一个参数 #{job_hash.inspect}")
  EmailDiscuss.process_email(job_hash)
rescue Exception => ex
  @logger.warn("处理#{job_hash.inspect}出现例外#{ex}")
end

loop do
  job = beanstalk.reserve
  job_hash = job.ybody
  case job_hash[:type]
  when "received_email"
    process_email(job_hash)
  else
    @logger.warn("警告！！不知道怎么处理 #{job_hash.inspect}")
  end
  job.delete
end