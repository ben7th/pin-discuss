worker_processes 3

listen '/web/2010/sockets/discuss_unicorn.sock', :backlog => 2048
timeout 30

stderr_path("#{File.dirname(__FILE__)}/../log/unicorn_error.log")
stdout_path("#{File.dirname(__FILE__)}/../log/unicorn.log")

pid_file = "/web/2010/pids/unicorn_pin_discuss.pid"
pid pid_file
preload_app true

before_fork do |server, worker|
  old_pid = pid_file + '.oldbin'
  if File.exists?(old_pid) && server.pid != old_pid
    begin
      Process.kill("QUIT", File.read(old_pid).to_i)
    rescue Errno::ENOENT, Errno::ESRCH
      # someone else did our job for us
    end
  end
end