workers Integer(ENV['WEB_CONCURRENCY'] || 2)
threads_count = Integer(ENV['RAILS_MAX_THREADS'] || 5)
threads threads_count, threads_count

preload_app!

rackup      DefaultRackup if defined?(DefaultRackup)
port        ENV['PORT']     || 3000
environment ENV['RACK_ENV'] || 'development'

# https://github.com/jeremyevans/sequel/blob/0e49e08d4b604546347b7ad18bbfbf684150a443/doc/fork_safety.rdoc

before_fork do
  Sequel::DATABASES.each(&:disconnect)
end
