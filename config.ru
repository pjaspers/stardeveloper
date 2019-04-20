require "bundler/setup"

require "shack"
sha = ENV["HEROKU_SLUG_COMMIT"] || "284246e6dc4a7a6b81064afc453d8e8dc0ef4d61"
Shack::Middleware.configure do |shack|
  shack.sha = sha
  shack.content = "<a href='https://github.com/pjaspers/stardeveloper/commit/{{sha}}'>{{short_sha}}</a>"
end
use Shack::Middleware

use Rack::Static, :urls => ['/stylesheets', '/javascripts', '/fonts/'], :root => 'public'

require "./app"
map('/')         { run App }
