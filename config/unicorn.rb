# worker 数量
worker_processes 3

<<<<<<< HEAD
# 日志位置
stderr_path("/web/2010/logs/unicorn-discuss-error.log")
stdout_path("/web/2010/logs/unicorn-discuss.log")

# 加载 超时设置 监听
=======
listen '/web/2010/sockets/discuss_unicorn.sock', :backlog => 2048
timeout 30

stderr_path("#{File.dirname(__FILE__)}/../log/unicorn_error.log")
stdout_path("#{File.dirname(__FILE__)}/../log/unicorn.log")

pid_file = "/web/2010/pids/unicorn_pin_discuss.pid"
pid pid_file
>>>>>>> f12cce68c9f6f79b3dd65f740d7eef90059e6e0e
preload_app true
timeout 30
listen '/web/2010/sockets/unicorn-discuss.sock', :backlog => 2048

pid_file_name = "/web/2010/pids/unicorn-discuss.pid"
pid pid_file_name

# REE GC
if GC.respond_to?(:copy_on_write_friendly=)
  GC.copy_on_write_friendly = true
end

before_fork do |server, worker|
  old_pid = pid_file_name + '.oldbin'
  if File.exists?(old_pid) && server.pid != old_pid
    begin
      Process.kill("QUIT", File.read(old_pid).to_i)
    rescue Errno::ENOENT, Errno::ESRCH
      # ...
    end
  end
end

after_fork do |server, worker|
  ActiveRecord::Base.establish_connection
end