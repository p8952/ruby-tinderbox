require_relative 'minitest_helper'

class TestWeb < Minitest::Test
	include Rack::Test::Methods

	def app
		RubyStats
	end

	def test_headings
		get '/outdated_gems'
		assert last_response.ok?
		assert last_response.body.include? '<h1>Outdated Gems</h1>'
	end
end
