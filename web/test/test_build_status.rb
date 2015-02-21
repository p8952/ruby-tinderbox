require_relative 'minitest_helper'

class TestWeb < Minitest::Test
	include Rack::Test::Methods

	def app
		RubyStats
	end

	def test_headings
		get '/build_status'
		assert last_response.ok?
		assert last_response.body.include? '<h1>Build Status (CI)</h1>'
	end
end
