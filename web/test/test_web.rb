require 'minitest/autorun'
require 'rack/test'
require_relative '../app'

class TestWeb < MiniTest::Unit::TestCase
	include Rack::Test::Methods

	def app
		RubyStats
	end

	def test_redirect
		get '/'
		follow_redirect!
		assert last_response.ok?
	end

	def test_ruby_targets
		get '/ruby_targets'
		assert last_response.ok?
		assert last_response.body.include? '<h3>Ruby Targets</h3>'
	end

	def test_outdated_gems
		get '/outdated_gems'
		assert last_response.ok?
		assert last_response.body.include? '<h3>Outdated Gems</h3>'
	end

	def test_build_status
		get '/build_status'
		assert last_response.ok?
		assert last_response.body.include? '<h3>Build Status (CI)</h3>'
	end

	def test_visualizations
		get '/visualizations'
		assert last_response.ok?
		assert last_response.body.include? '<h3>Number of Packages per Ruby Target:</h3>'
	end
end
