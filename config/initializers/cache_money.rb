#require 'cache_money'
#require 'memcache'
#
#config = YAML.load(IO.read(File.join(RAILS_ROOT, "config", "memcached.yml")))[RAILS_ENV]
#$memcache = MemCache.new(config)
#$memcache.servers = config['servers']
#
#$memcache = Cash::Mock.new if RAILS_ENV == 'test'
#
#$local = Cash::Local.new($memcache)
#$lock = Cash::Lock.new($memcache)
#$cache = Cash::Transactional.new($local, $lock)
#
#module CacheMoneyUpdateAllPatch
#  def self.included(active_record_class)
#    active_record_class.class_eval do
#      extend ClassMethods
#    end
#  end
#
#  module ClassMethods
#    def self.extended(active_record_class)
#      class << active_record_class
#        alias_method_chain :update_all, :cache
#      end
#    end
#
#    def update_all_with_cache(updates, conditions = nil, options = {})
#      # 这里要先更新缓存，否则update_all完成后，查询到的结果集不一样了
#      $cache.transaction do
#        find(:all, :conditions=>conditions).each do |m|
#          expire_caches m
#        end
#        raise if !update_all_without_cache(updates,conditions,options)
#      end
#    end
#
#  end
#end
#
#class ActiveRecord::Base
#  is_cached :repository => $cache
#  include ::CacheMoneyUpdateAllPatch
#end