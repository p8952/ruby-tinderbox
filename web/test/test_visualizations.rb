require_relative 'minitest_helper'

class TestWeb < Minitest::Test
	include Rack::Test::Methods

	def app
		RubyTinderbox
	end

	def test_heading
		get '/visualizations'
		assert last_response.ok?
		assert last_response.body.include? '<h1>Visualizations</h1>'
		assert last_response.body.include? '<h2>Number of Packages per Ruby Target</h2>'
		assert last_response.body.include? '<h2>Number of Outdated Gems</h2>'
		assert last_response.body.include? '<h2>Number of Packages per Build Result</h2>'
	end
end
