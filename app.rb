require "sequel"
require "sinatra"
require 'csv'
require 'time'

if ENV["RACK_ENV"] == "test"
  $db = Sequel.sqlite
else
  $db = Sequel.connect(ENV['DATABASE_URL'] || 'sqlite://stardeveloper.db')
end


$db.create_table? :tweets do
  primary_key :id
  String :name
  String :text
  Time :posted_at
  String :tweet_id
end rescue nil

class Tweet < Sequel::Model

  def lines(max_chars: 16)
    (text + " ").scan(/.{1,#{max_chars}}[ ,;:]/).map(&:strip)
  end

  def link
    "https://twitter.com/#{self.name}/status/#{self.tweet_id}"
  end

  def permalink
    "/#{self.name}/status/#{self.tweet_id}"
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

    def width(s, size = 16)
      s.downcase.chars.inject(0) do |r, c|
        rhinus_size_class = {
          " " => 6,
          "#" => 12,
          "@" => 14,
          ":" => 3,
          ";" => 3,
          "," => 3,
          "'" => 3,
          '"' => 3,
          "." => 3,
          "‘" => 3,
          "’" => 3,
          "a" => 10,
          "b" => 8,
          "c" => 9,
          "d" => 9,
          "e" => 8,
          "f" => 8,
          "g" => 10,
          "h" => 10,
          "i" => 3,
          "j" => 7,
          "k" => 11,
          "m" => 14,
          "n" => 11,
          "o" => 10,
          "q" => 10,
          "r" => 10,
          "s" => 10,
          "t" => 10,
          "u" => 10,
          "v" => 11,
          "w" => 15,
          "x" => 10,
          "y" => 10,
          "z" => 9,
        }

        church_size_class = {
          " " => 6,
          "#" => 12,
          "@" => 13,
          ":" => 6,
          ";" => 6,
          "," => 6,
          "'" => 6,
          '"' => 9,
          "." => 6,
          "‘" => 6,
          "’" => 6,
          "a" => 13,
          "b" => 11,
          "c" => 11,
          "d" => 12,
          "e" => 11,
          "g" => 12,
          "h" => 12,
          "i" => 6,
          "j" => 7,
          "k" => 13,
          "m" => 16,
          "n" => 13,
          "o" => 12,
          "q" => 12,
          "r" => 12,
          "s" => 11,
          "t" => 11,
          "u" => 12,
          "v" => 13,
          "w" => 17,
          "x" => 12,
          "y" => 11,
          "z" => 11,
        }
        size_class = rhinus_size_class.fetch(c, 10)
        r += (size_class / 16.0) * size.to_f
        r
      end + (s.chars.select {|c| c != " "}.length) * 1.8
    end

    def meta_attributes(tweet)
      [
        {property: "og:type", content: "website"},
        {property: "og:url", content: request.base_url},
        {property: "og:title", content: "#stardeveloper"},
        {property: "og:description", content: tweet.text.gsub("'", '"')},
        {property: "og:image", content: [request.base_url, "images/star_og_image.png"].join("/")},
        {name: "twitter:card", content: "summary"},
        {name: "twitter:site", content: "#stardeveloper"},
        {name: "twitter:creator", content: "@pjaspers"}
      ].map do |data|
        data.map do |k,v|
          "#{k}='#{v}'"
        end.join(" ")
      end
    end
  end

  get "/debug" do
    erb :debug
  end

  get "/developer/:developer" do
    @tweets = Tweet.where( name: params[:developer] )
    erb :list
  end

  get "/tweet/:tweet_id" do
    @tweet = Tweet.where( tweet_id: params[:tweet_id] ).first
    erb :index
  end

  get "/:name/status/:tweet_id" do
    @tweet = Tweet.where( tweet_id: params[:tweet_id] ).first
    @is_permalink = true
    erb :index
  end

  get '/' do
    @tweet = Tweet.all.sample
    @text = @tweet.text.concat(" ")
    @lines = @text.scan(/.{1,16}[ ,;:]/).map(&:strip)
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
