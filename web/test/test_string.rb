require_relative 'minitest_helper'

class TestString < MiniTest::Unit::TestCase
	def test_camel_case_with_default_delimiter
		assert_equal 'Camel Case', 'camel case'.camelcase
	end

	def test_camel_case_with_other_delimiter
		assert_equal 'Camel_Case', 'camel_case'.camelcase('_')
	end
end
