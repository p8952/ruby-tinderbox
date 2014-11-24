require 'minitest/autorun'
require_relative '../app'

class TestString < MiniTest::Unit::TestCase
	def test_string_can_camel_case_with_default_delimiter
		assert_equal 'Camel Case', 'camel case'.camelcase
	end

	def test_string_can_camel_case_with_other_delimiter
		assert_equal 'Camel_Case', 'camel_case'.camelcase('_')
	end
end
