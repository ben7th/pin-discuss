require 'rubygems'
require 'beanstalk-client'
require File.join(File.dirname(__FILE__), '../..', 'config', 'environment') if !defined?(RAILS_ROOT)

beanstalk_config = YAML::load(File.open("#{RAILS_ROOT}/config/beanstalk.yml"))
address = beanstalk_config[RAILS_ENV]["address"]

beanstalk = Beanstalk::Pool.new(address)

@logger = Logger.new("#{RAILS_ROOT}/log/queue.#{Rails.env}.log")
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