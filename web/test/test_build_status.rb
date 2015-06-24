require_relative 'minitest_helper'

class TestWeb < Minitest::Test
	include Rack::Test::Methods

	def app
		RubyTinderbox
	end

	def test_heading
		get '/build_status'
		assert last_response.ok?
		assert last_response.body.include? '<h1>Build Status (CI)</h1>'
	end

	def test_table
		get '/build_status'
		assert last_response.ok?
		assert last_response.body.include? 'lorem-ipsum/dolor-1.2.3'
		assert last_response.body.include? '2012-12-12'
		assert last_response.body.include? 'Succeeded'
		assert last_response.body.include? '1 Build(s)'
	end
end
