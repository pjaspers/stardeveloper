require "bundler/setup"
require "./app"
use Rack::Static, :urls => ['/stylesheets', '/javascripts'], :root => 'public'
map('/')         { run App }
