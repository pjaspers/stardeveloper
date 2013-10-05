require "bundler/setup"
require "./app"
use Rack::Static, :urls => ['/stylesheets', '/javascripts', '/fonts/'], :root => 'public'
map('/')         { run App }
