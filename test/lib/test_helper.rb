# frozen_string_literal: true
ENV["RACK_ENV"] = "test"
require_relative '../test_helper'
require_relative '../../lib/mastodon'

require 'webmock/minitest'
