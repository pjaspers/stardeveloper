require "sequel"
require "sinatra"

$db = Sequel.connect(ENV['DATABASE_URL'] || 'sqlite://stardeveloper.db')

$db.create_table :tweets do
  primary_key :id
  String :name
  String :text
  Time :posted_at
  String :tweet_id
end rescue nil

class Tweet < Sequel::Model
end

class App < Sinatra::Base

  enable :inline_templates

  get '/' do
    t = Tweet.all.sample
    @message = t.text
    @link = "http://twitter.com/#{t.name}/status/#{t.tweet_id}"
    erb :index
  end
end

__END__


@@layout
<html>
<head>
<title>#stardeveloper</title>
<style>
h1 {
	text-align: center;
	font-family: Verdana, Arial, Helvetica, sans-serif;
	font-size: 120px;
	font-weight: bold;
	padding-top: 50px;
}

span {
	text-align: center;
}

* { text-align: center; font-family: Verdana, Arial, Helvetica, sans-serif; }
</style>
<head>
<body>
<%= yield %>
</body>
</html>

@@index
<h1><%=@message%></h1>
<span><a href="<%= @link %>"><%= @link %></a></span>
