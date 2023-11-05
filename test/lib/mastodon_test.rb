require_relative "test_helper"

class MastodonTest < Test
  it "calls the right url and token" do
    toots = JSON.parse(File.read(root.join("test/fixtures/tag_response.json")))
    mastodon = Mastodon.new(token: "hi", tag: "stardeveloper", host: "mastodon.social")
    stub_request(:get, "https://mastodon.social/api/v1/timelines/tag/stardeveloper").
      with(
        headers: {
	        'Accept'=>'*/*',
	        'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
	        'Authorization'=>'Bearer hi',
	        'Host'=>'mastodon.social',
	        'User-Agent'=>'Ruby'
        }).
      to_return_json(body: toots)

    response = mastodon.fetch

    assert_equal toots, response
  end

  it "running it twice will skip duplicates" do
    toots = JSON.parse(File.read(root.join("test/fixtures/tag_response.json")))
    mastodon = Mastodon.new(token: "hi", tag: "stardeveloper", host: "mastodon.social")
    stub_request(:get, "https://mastodon.social/api/v1/timelines/tag/stardeveloper").to_return_json(body: toots)

    mastodon.call
    after_one = $db[:updates].count
    mastodon.call

    assert_equal after_one, $db[:updates].count
  end

  describe "#persist"do
    before do
      @toot = JSON.parse(File.read(root.join("test/fixtures/tag_response.json"))).first
      mastodon = Mastodon.new(token: "hi", tag: "stardeveloper", host: "example.social")
      mastodon.persist([@toot])

      @update = $db[:updates].where(update_id: @toot["id"]).first
    end

    it "name" do
      assert_equal "teufen", @update[:name]
    end

    it "html" do
      expected = "<p>OH: Ja, dat snap ik nooit, dus ik lees daar een beetje over</p><p><a href=\"https://mas.to/tags/stardeveloper\" class=\"mention hashtag\" rel=\"nofollow noopener noreferrer\" target=\"_blank\">#<span>stardeveloper</span></a></p>"

      assert_equal expected, @update[:html]
    end

    it "posted_at" do
      # mastodon is utc, we store it in utc
      assert_equal Time.parse("2022-11-30T16:02:47.000Z"), @update[:posted_at]
    end

    it "raw" do
      assert_equal @toot, JSON.parse(@update[:raw])
    end

    it "text" do
      assert_equal "OH: Ja, dat snap ik nooit, dus ik lees daar een beetje over #stardeveloper", @update[:text]
    end

    it "kind" do
      assert_equal "mastodon", @update[:kind]
    end

    it "host" do
      assert_equal "example.social", @update[:host]
    end
  end
end
