# frozen_string_literal: true

require 'test_helper'
require 'English'

class TestRLox < Minitest::Test
  def test_that_it_passes_the_official_test_suite
    in_craftinginterpreters_system! 'make jlox'

    assert_equal 0, $CHILD_STATUS

    in_craftinginterpreters_system! 'make get'

    assert_equal 0, $CHILD_STATUS

    in_craftinginterpreters_system! 'dart tool/bin/test.dart jlox --interpreter ../exe/rlox'

    assert_equal 0, $CHILD_STATUS
  end

  private

  def in_craftinginterpreters_system!(command_line)
    craftinginterpreters_dir = File.join __dir__, '../craftinginterpreters'

    system command_line, { chdir: craftinginterpreters_dir }
  end
end
