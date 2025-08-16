# Puma configuration
max_threads_count = ENV.fetch("RAILS_MAX_THREADS", 5).to_i
min_threads_count = ENV.fetch("RAILS_MIN_THREADS", max_threads_count).to_i
threads min_threads_count, max_threads_count

environment ENV.fetch("RAILS_ENV", "development")

# Bind to 0.0.0.0 and use Railway's PORT
bind "tcp://0.0.0.0:#{ENV.fetch('PORT', 3000)}"

pidfile ENV.fetch("PIDFILE", "tmp/pids/server.pid")

worker_count = ENV.fetch("WEB_CONCURRENCY", 2).to_i
workers worker_count if worker_count > 1

preload_app!
plugin :tmp_restart
