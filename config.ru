require "bundler/setup"
require "./app"
map('/')         { run App }
use Rack::Static, :urls => ['/stylesheets', '/javascripts'], :root => 'public'
