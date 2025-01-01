# frozen_string_literal: true

require 'test_helper'

class TestRLoxAstPrinter < Minitest::Test
  def test_that_it_works_as_expected
    expression = RLox::Expr::Binary.new(
      RLox::Expr::Unary.new(
        RLox::Token.new(RLox::TokenType::MINUS, '-', nil, 1),
        RLox::Expr::Literal.new(123)
      ),
      RLox::Token.new(RLox::TokenType::STAR, '*', nil, 1),
      RLox::Expr::Grouping.new(
        RLox::Expr::Literal.new(45.67)
      )
    )

    assert_equal '(* (- 123) (group 45.67))', RLox::AstPrinter.new.print(expression)
  end
end
