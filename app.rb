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
    @name = t.name
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
  <link rel="stylesheet" href="/stylesheets/style.css">
<head>
<body>
<div id="hear-ye">
  <%= yield %>
</div>

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
<hr class="double" />
<h1>#STARDEVELOPER</h1>
<hr class="thick"/>
<div id="themessage"><p><%=@message%></p></div>
<hr class="dixit">
<div id="themessager"><a href="<%= @link %>"><%= @name %></a></div>
<hr class="thick"/>


@@list
<hr class="double" />
<h1>#STARDEVELOPER</h1>
<hr class="thick"/>
<ul>
<% Tweet.order(:posted_at).each_with_index do |tweet, index| %>
<li class="<%= (index % 2 == 0) ? "even": "less-even" %>">
<%= tweet.text %> <a href="<%= tweet.link %>"><%= tweet.name %></a>
</li>
<% end %>
</ul>
