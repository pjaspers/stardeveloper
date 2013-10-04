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

  enable :inline_templates

  helpers do
  end

  get '/' do
    t = Tweet.all.sample
    @message = t.text
    @link = "http://twitter.com/#{t.name}/status/#{t.tweet_id}"
    erb :index
  end

  get '/list' do
    erb :list
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

ul {
  margin-left: 20px;
  margin-right: 20px;
  margin-top: 60px;
}
ul li {
  margin-left: 20px;
  font-size: 1em;
  font-style: italic;
  list-style-type: lower-roman;
}
</style>
<head>
<body>
<%= yield %>

<script type="text/javascript">
  // Yes I like stats, #sosume
  var _gaq = _gaq || [];
  _gaq.push(['_setAccount', 'UA-19720163-2']);
  _gaq.push(['_trackPageview']);

  (function() {
    var ga = document.createElement('script'); ga.type = 'text/javascript'; ga.async = true;
    ga.src = ('https:' == document.location.protocol ? 'https://ssl' : 'http://www') + '.google-analytics.com/ga.js';
    var s = document.getElementsByTagName('script')[0]; s.parentNode.insertBefore(ga, s);
  })();

</script>
</body>
</html>

@@index
<h1><%=@message%></h1>
<span><a href="<%= @link %>"><%= @link %></a></span>

@@list
<ul>
<% Tweet.order(:posted_at).each_with_index do |tweet, index| %>
<li>
<%= tweet.text %> <a href="<%= tweet.link %>"><%= tweet.name %></a>
</li>
<% end %>
</ul>
