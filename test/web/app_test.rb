# frozen_string_literal: true
require_relative 'test_helper'

class AppTest < WebTest
  include Rack::Test::Methods

  def create_tweet(**options)
    t = Update.find_or_create(update_id: SecureRandom.uuid)
    t.name = options[:username] || "itme"
    t.posted_at = options[:posted_at] || Time.now
    t.text = options[:text] || "o hai #stardeveloper"
    t.save
    t
  end

  it "/" do
    create_tweet
    get "/"
    assert_includes last_response.body, "#didyourender"
  end

  it "/debug" do
    get "/debug"

    assert_includes last_response.body, "#didyourender"
  end

  it "/developer/:developer" do
    create_tweet(username: "bob")
    get "/developer/bob"
    assert_includes last_response.body, "#didyourender"
  end

  it "/:name/status/:update_id" do
    t = create_tweet(text: "You hoser!")
    get "/doesn-t-matter/status/#{t.update_id}"

    assert_includes last_response.body, "You hoser!"
  end

  it "/list" do
    100.times { create_tweet(text: "You hoser!") }
    get "/list"
    assert_includes last_response.body, "#didyourender"
  end

  it "/league" do
    100.times { create_tweet(username: SecureRandom.alphanumeric(10)) }
    get "/league"
    assert_includes last_response.body, "#didyourender"
  end
end
