require "sequel"
require "net/http"
require "json"
require "nokogiri"

require_relative "../db"

class Mastodon
  def initialize(token:, tag:, host:)
    @token = token
    @tag = tag
    @host = host
  end

  def call
    toots = fetch
    persist(toots)
  end

  def fetch
    uri = URI.parse("https://#{@host}/api/v1/timelines/tag/#{@tag}")
    request = Net::HTTP::Get.new(uri)
    request["Authorization"] = "Bearer #{@token}"

    req_options = {
      use_ssl: uri.scheme == "https",
    }

    response = Net::HTTP.start(uri.hostname, uri.port, req_options) do |http|
      http.request(request)
    end

    JSON.parse(response.body)
  end

  def persist(toots)
    toots.each do |toot|
      id, content, created_at = toot.values_at("id", "content", "created_at")
      username = toot.dig("account", "username")
      created_at = Time.parse(created_at)
      text = Nokogiri::HTML(content).text.gsub(/(?<!\s)(#)/, " #")
      $db[:updates].insert_conflict.insert(
        update_id: id,
        name: username,
        text: text,
        html: content,
        posted_at: created_at,
        raw: toot.to_json,
        kind: "mastodon",
        host: @host,
      )
    end
  end
end
