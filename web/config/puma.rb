workers Integer(ENV['PUMA_WORKERS'] || 5)
threads Integer(ENV['MIN_THREADS'] || 1), Integer(ENV['MAX_THREADS'] || 16)

preload_app!

port ENV['PORT'] || 9292
environment ENV['RACK_ENV'] || 'development'
