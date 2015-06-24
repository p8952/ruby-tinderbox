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

	def test_heading
		get '/ruby_targets'
		assert last_response.ok?
		assert last_response.body.include? '<h1>Ruby Targets</h1>'
	end

	def test_table
		get '/ruby_targets'
		assert last_response.ok?
		assert last_response.body.include? 'lorem-ipsum/dolor-1.2.3'
		assert last_response.body.include? 'ruby19'
		assert last_response.body.include? 'ruby20'
		assert last_response.body.include? 'ruby21'
		assert last_response.body.include? 'ruby22'
	end
end
