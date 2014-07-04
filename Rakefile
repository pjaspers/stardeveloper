#!/usr/bin/env rake

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
