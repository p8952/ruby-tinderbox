require_relative 'minitest_helper'

class TestWeb < Minitest::Test
	include Rack::Test::Methods

	def app
		RubyTinderbox
	end

	def test_redirect
		get '/'
		follow_redirect!
		assert last_response.ok?
		assert last_response.body.include? '<h1>Ruby Targets</h1>'
	end

	def test_headings
		get '/ruby_targets'
		assert last_response.ok?
		assert last_response.body.include? '<h1>Ruby Targets</h1>'
	end
end
