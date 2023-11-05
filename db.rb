require 'sequel/core'

if ENV["RACK_ENV"] == "test"
  $db = Sequel.connect("sqlite://stardeveloper_test.db")
else
  $db = Sequel.connect(ENV['DATABASE_URL'] || 'sqlite://stardeveloper.db')
end
