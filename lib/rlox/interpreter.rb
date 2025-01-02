# frozen_string_literal: true

class RLox
  class Interpreter
    def visit_literal_expr(expr)
      expr.value
    end

    def visit_unary_expr(expr)
      right = evaluate expr.right

      case expr.operator.type
      when TokenType::BANG then !truthy?(right)
      when TokenType::MINUS
        check_number_operand expr.operator, right
        -Float(right)
      end
    end

    def visit_grouping_expr(expr)
      evaluate expr.expression
    end

    def visit_binary_expr(expr)
      left = evaluate expr.left
      right = evaluate expr.right

      case expr.operator.type
      when TokenType::BANG_EQUAL then !equal?(left, right)
      when TokenType::EQUAL_EQUAL then equal?(left, right)
      when TokenType::GREATER
        check_number_operands expr.operator, left, right
        Float(left) > Float(right)
      when TokenType::GREATER_EQUAL
        check_number_operands expr.operator, left, right
        Float(left) >= Float(right)
      when TokenType::LESS
        check_number_operands expr.operator, left, right
        Float(left) < Float(right)
      when TokenType::LESS_EQUAL
        check_number_operands expr.operator, left, right
        Float(left) <= Float(right)
      when TokenType::MINUS
        check_number_operands expr.operator, left, right
        Float(left) - Float(right)
      when TokenType::PLUS
        return left + right if (left.is_a?(Float) && right.is_a?(Float)) || (left.is_a?(String) && right.is_a?(String))

        raise RLox::RuntimeError expr.operator, 'Operands must be two numbers or two strings.'
      when TokenType::SLASH
        check_number_operands expr.operator, left, right
        Float(left) / Float(right)
      when TokenType::STAR
        check_number_operands expr.operator, left, right
        Float(left) * Float(right)
      end
    end

    private

    def check_number_operand(operator, operand)
      return if operand.is_a? Float

      raise RLox::RuntimeError operator, 'Operand must be a number.'
    end

    def check_number_operands(operator, left, right)
      return if left.is_a?(Float) && right.is_a?(Float)

      raise RLox::RuntimeError operator, 'Operand must be numbers.'
    end

    def evaluate(expr)
      expr.accept self
    end

    def truthy?(object)
      object
    end

    def equal?(one, other)
      one == other
    end
  end
end
