require "sequel"
require "sinatra"
require 'csv'
require 'time'

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
    def letterspacing_for_name(name)
      length = (name || "").length
      if length <= 4
        70
      else
        50 - (length - 5)*4
      end
    end
  end

  get "/developer/:developer" do
    @tweets = Tweet.where( name: params[:developer] )
    erb :list
  end

  get "/tweet/:tweet_id" do
    @tweet = Tweet.where( tweet_id: params[:tweet_id] ).first
    erb :index
  end

  get '/' do
    @tweet = Tweet.all.sample
    erb :index
  end

  get '/list' do
    @tweets = Tweet
    erb :list
  end

  get '/league' do
    erb :league
  end

  get '/csv' do
    erb :csv
  end

  post '/csv' do
    tempfile = params[:file][:tempfile]
    username = params[:username]
    tweets = [];
    output = []
    puts tempfile.path
    CSV.foreach(tempfile.path, encoding: 'utf-8') do |r|
      if !!r.detect{|s| s =~ /stardeveloper/}
        tweets << r
      end
    end
    output << "Found #{tweets.count} tweets"
    tweets.each do |tweet|
      t = Tweet.find_or_create(tweet_id: tweet.first)
      t.name = username
      t.posted_at = Time.parse(tweet[3])
      t.text = tweet[5]
      t.save
      output << ("Saving tweet: %s" % t.text)
    end
    output.join("\n")
  end
end
