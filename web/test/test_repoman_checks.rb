require_relative 'minitest_helper'

class TestWeb < Minitest::Test
	include Rack::Test::Methods

	def app
		RubyTinderbox
	end

	def test_heading
		get '/repoman_checks'
		assert last_response.ok?
		assert last_response.body.include? '<h1>Repoman Checks (QA)</h1>'
	end
end
