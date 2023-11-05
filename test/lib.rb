# frozen_string_literal: true
ENV['NO_AUTOLOAD'] = '1'
Dir['./test/lib/*_test.rb'].each{|f| require f}
