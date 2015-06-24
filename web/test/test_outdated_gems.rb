require_relative 'minitest_helper'

class TestWeb < Minitest::Test
	include Rack::Test::Methods

	def app
		RubyTinderbox
	end

	def test_heading
		get '/outdated_gems'
		assert last_response.ok?
		assert last_response.body.include? '<h1>Outdated Gems</h1>'
	end

	def test_table
		get '/outdated_gems'
		assert last_response.ok?
		assert last_response.body.include? 'lorem-ipsum/dolor-1.2.3'
		assert last_response.body.include? '1.2.3'
		assert last_response.body.include? '1.2.4'
	end
end
