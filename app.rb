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
<style>
@font-face {
  font-family: "Chunkfive";
  src: url('/fonts/Chunkfive-webfont.ttf') format('truetype'), url('/fonts/Chunkfive-webfont.otf') format('opentype');
}

body {
  font-family: "Chunkfive";
  background-color: black;
}
hr.double {
  padding: 0;
  border: 0;
  border-top: thick double white;
  color: white;
  text-align: center;
}
hr.double:after {
    content: "640K is enough";
    display: inline-block;
    position: relative;
    top: -0.7em;
    font-size: 1.5em;
    padding: 0 0.25em;
    background: black;
}
hr.dixit {
  padding: 0;
  border: 0;
  border-top: 3px solid white;
  color: white;
  text-align: center;
}
hr.dixit:after {
    content: "Dixit";
    display: inline-block;
    position: relative;
    top: -0.5em;
    font-size: 1.5em;
    padding: 0 0.25em;
    background: black;
}

hr.thick {
  border-top: 3px solid white;
}
#hear-ye {
margin-top: 20px;
  width: 80%;
display: block;
  margin-left: auto;
  margin-right: auto;
}
h1 {
color: #FF4358;
font-size: 4em;
text-align: justify;
  text-justify: newspaper;
letter-spacing: -3px;
margin: 0px;
text-align: center;
font-size: 6em;
font-weight: lighter;
    overflow: hidden; /* to hide anything that doesn't fit in the containing element. */
    white-space: nowrap; /* to make sure the line doesn't break when it is longer than the containing div. */
    text-overflow: ellipsis; /* to do what you want. */
}
#themessage {
font-size: 4em;
}
#themessage p {
text-transform:uppercase;
margin:3px;
text-align: center;
color: white;
}
#themessager {
text-align: center;
text-transform: uppercase;
}
#themessager a{
color: #E3EDE3;
font-size: 3em;
}

ul li {
margin-top:10px;
  font-size: 1.8em;
text-align: right;
  list-style-type: lower-roman;
  color: white;
font-weight: lighter;
}
ul li.even {
  color: #BEC7BF;
}
ul li a {
color: #FF4358;
}

</style>
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
