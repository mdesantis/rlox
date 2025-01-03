# frozen_string_literal: true

class RLox
  class Interpreter
    def initialize
      @environment = Environment.new
    end

    def interpret(statements)
      statements.each do |statement|
        execute statement
      end
    rescue RLox::RuntimeError => error
      RLox.runtime_error error
    end

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

        raise RLox::RuntimeError.new expr.operator, 'Operands must be two numbers or two strings.'
      when TokenType::SLASH
        check_number_operands expr.operator, left, right
        Float(left) / Float(right)
      when TokenType::STAR
        check_number_operands expr.operator, left, right
        Float(left) * Float(right)
      end
    end

    def visit_expression_stmt(stmt)
      evaluate stmt.expression
      nil
    end

    def visit_print_stmt(stmt)
      value = evaluate stmt.expression
      puts stringify value
      nil
    end

    def visit_var_stmt(stmt)
      value = nil
      value = evaluate stmt.initializer unless stmt.initializer.nil?

      environment.define stmt.name.lexeme, value
      nil
    end

    def visit_variable_expr(expr)
      environment.get expr.name
    end

    def visit_assign_expr(expr)
      value = evaluate expr.value
      environment.assign expr.name, value
      value
    end

    private

    attr_reader :environment

    def execute(stmt)
      stmt.accept self
    end

    def check_number_operand(operator, operand)
      return if operand.is_a? Float

      raise RLox::RuntimeError.new operator, 'Operand must be a number.'
    end

    def check_number_operands(operator, left, right)
      return if left.is_a?(Float) && right.is_a?(Float)

      raise RLox::RuntimeError.new operator, 'Operand must be numbers.'
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

    def stringify(object)
      return 'nil' if object.nil?

      if object.is_a? Float
        text = object.to_s
        text = text[...-2] if text.end_with? '.0'
        return text
      end

      object.to_s
    end
  end
end
