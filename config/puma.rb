max_threads_count = ENV.fetch("RAILS_MAX_THREADS", 5)
min_threads_count = ENV.fetch("RAILS_MIN_THREADS", max_threads_count)
threads min_threads_count, max_threads_count

environment ENV.fetch("RAILS_ENV", "production")

# Bind to 0.0.0.0 and use Railway PORT
port ENV.fetch("PORT", 3000)
bind "tcp://0.0.0.0:#{ENV.fetch('PORT', 3000)}"

pidfile ENV.fetch("PIDFILE", "tmp/pids/server.pid")

worker_count = Integer(ENV.fetch("WEB_CONCURRENCY", 2))
workers worker_count if worker_count > 1

# Only for development
worker_timeout 3600 if ENV.fetch("RAILS_ENV", "production") != "production"

preload_app!
plugin :tmp_restart
