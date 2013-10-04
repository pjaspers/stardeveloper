require "twitter"
require 'sequel'

DB = Sequel.connect(ENV['DATABASE_URL'] || 'sqlite://stardeveloper.db')
DB.create_table? :tweets do
  primary_key :id
  String :name
  String :text
  Time :posted_at
  String :tweet_id
end
class Tweet < Sequel::Model
end

class Catcher
  def initialize
    setup_db
    setup_twitter
  end

  def setup_db

  end

  def setup_twitter
    Twitter.configure do |config|
      config.consumer_key = "***REMOVED***"
      config.consumer_secret = "***REMOVED***"
      config.oauth_token = "***REMOVED***"
      config.oauth_token_secret = "***REMOVED***"
    end
  end

  def collect_with_max_id(collection=[], max_id=nil, &block)
    tweets = yield(max_id)
    return collection if tweets.nil?
    collection += tweets
    tweets.empty? ? collection.flatten : collect_with_max_id(collection, tweets.last.id - 1, &block)
  end

  def decode_full_text(tweet, decode_full_urls = false)
    require 'htmlentities'
    text = HTMLEntities.new.decode(tweet.full_text)
    text = decode_urls(text, tweet.urls) if decode_full_urls
    text
  end

  def fetch_user(username)
    opts = {:count => 200}

    max_id = (Tweet.where(name: username).order(:tweet_id).limit(1).last || {}).fetch(:tweet_id, nil)
    tweets = collect_with_max_id do |max_id|
      puts "Fetching #{username} (#{max_id})"
      opts[:max_id] = max_id unless max_id.nil?
      Twitter.user_timeline(username, opts)
    end

    tweets.select do |tweet|
      /stardeveloper/i.match(tweet.full_text)
    end

  rescue
    "Something went wrong fetching #{username}"
    []
  end

  def deep_crawl_users
    users = %w(mathiasbaert maartekes inferis janvanryswyck ridingwolf fousa bobvlanduyt evertvdbruel atog 10to1 davydevuysdere tomklaasen junkiesxl)
    users.each do |user|
      tweets = fetch_user(user)
      tweets.each do |tweet|
        process_tweet(tweet)
      end
    end
  end

  def process_tweet(tweet)
    name = tweet.from_user.downcase
    puts "%s: %s" % [tweet.from_user, decode_full_text(tweet)]
    t = Tweet.find_or_create(:tweet_id => tweet.id.to_s)
    t.name = name
    t.posted_at = tweet.send :created_at
    t.text = tweet.full_text
    t.save
  end

  def crawl_hashtag
    puts "Performing search"
    Twitter.search("#stardeveloper", since_id: Tweet.order(:posted_at).last.tweet_id, result_type: :recent).statuses.each do |tweet|
      process_tweet(tweet)
    end
    puts "Done."
  end
end
