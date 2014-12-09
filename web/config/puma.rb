threads Integer(ENV['MIN_THREADS'] || 1), Integer(ENV['MAX_THREADS'] || 16)
workers Integer(ENV['PUMA_WORKERS'] || 4)

environment ENV['RACK_ENV'] || 'development'
port ENV['PORT'] || 9292

daemonize
pidfile 'var/run/puma.pid'
stdout_redirect 'var/log/puma.log', 'var/log/puma_error.log'
