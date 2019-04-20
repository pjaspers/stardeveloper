#!/usr/bin/env rake

task :test do
  $LOAD_PATH.unshift('test')
  Dir.glob("./test/*_test.rb") { |f| require f }
end

task default: :test

desc 'Search for new mentions'
task :crawl_for_tag do
  load "catcher.rb"
  Catcher.new.crawl_hashtag
end

desc 'consoling all the thing'
task :console do
  require 'irb'
  require 'irb/completion'
  require './app' # You know what to do.
  ARGV.clear
  IRB.start
end
