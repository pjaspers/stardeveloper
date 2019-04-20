# test_helper.rb
ENV["RACK_ENV"] = "test"
require "minitest/autorun"
require "minitest/pride"
require "rack/test"
require "securerandom"

require File.expand_path "../../app.rb", __FILE__

class MyAppTest < Minitest::Test
  include Rack::Test::Methods

  def app
    App
  end

  def create_tweet(**options)
    t = Tweet.find_or_create(tweet_id: SecureRandom.uuid)
    t.name = options[:username] || "itme"
    t.posted_at = options[:posted_at] || Time.now
    t.text = options[:text] || "o hai #stardeveloper"
    t.save
    t
  end

  def test_it_at_least_renders
    create_tweet
    get "/"
    assert_includes last_response.body, "#didyourender"
  end

  def test_it_can_do_a_single
    t = create_tweet(text: "You hoser!")
    get "/tweet/#{t.tweet_id}"
    assert_includes last_response.body, "You hoser!"
  end

  def test_list
    100.times { create_tweet(text: "You hoser!") }
    get "/list"
    assert_includes last_response.body, "#didyourender"
  end

  def test_league
    100.times { create_tweet(username: SecureRandom.alphanumeric(10)) }
    get "/league"
    assert_includes last_response.body, "#didyourender"
  end

  def test_developer
    create_tweet(username: "bob")
    get "/developer/bob"
    assert_includes last_response.body, "#didyourender"
  end
end
