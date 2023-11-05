# frozen_string_literal: true
ENV["RACK_ENV"] = "test"
require_relative '../test_helper'
require_relative '../../app'

# require 'capybara'
# require 'capybara/dsl'
require 'rack/test'

class WebTest < Test
  include Rack::Test::Methods

  def app
    App
  end
end
