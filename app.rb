require "sequel"
require "sinatra"

$db = Sequel.connect(ENV['DATABASE_URL'] || 'sqlite://stardeveloper.db')

$db.create_table? :tweets do
  primary_key :id
  String :name
  String :text
  Time :posted_at
  String :tweet_id
end rescue nil

class Tweet < Sequel::Model

  def link
    "http://twitter.com/#{self.name}/status/#{self.tweet_id}"
  end
end

class App < Sinatra::Base

  helpers do
  end

  get '/' do
    t = Tweet.all.sample
    @message = t.text
    @name = t.name
    @link = "http://twitter.com/#{t.name}/status/#{t.tweet_id}"
    erb :index
  end

  get '/list' do
    erb :list
  end
end
