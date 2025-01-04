# frozen_string_literal: true

class RLox
  class Interpreter
    class ClockFn
      def arity
        0
      end

      def callable?
        true
      end

      def call(_interpreter, _arguments)
        Process.clock_gettime Process::CLOCK_REALTIME, :float_millisecond
      end

      def to_s
        '<native fn>'
      end
    end

    attr_reader :globals

    def initialize
      @globals = Environment.new
      @environment = @globals
      @locals = {}

      @globals.define 'clock', ClockFn.new
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

    def visit_function_stmt(stmt)
      function = RLox::Function.new stmt, environment
      environment.define stmt.name.lexeme, function
      nil
    end

    def visit_print_stmt(stmt)
      value = evaluate stmt.expression
      puts stringify value
      nil
    end

    def visit_return_stmt(stmt)
      value = nil
      value = evaluate stmt.value if stmt.value

      raise Return.new(value)
    end

    def visit_var_stmt(stmt)
      value = nil
      value = evaluate stmt.initializer if stmt.initializer

      environment.define stmt.name.lexeme, value
      nil
    end

    def visit_variable_expr(expr)
      look_up_variable expr.name, expr
    end

    def visit_assign_expr(expr)
      value = evaluate expr.value

      distance = locals[expr]
      if distance
        environment.assign_at distance, expr.name, value
      else
        globals.assign expr.name, value
      end

      value
    end

    def visit_block_stmt(stmt)
      execute_block stmt.statements, Environment.new(environment)
      nil
    end

    def visit_class_stmt(stmt)
      environment.define stmt.name.lexeme, nil

      methods = {}
      stmt.methods.each do |method|
        function = Function.new method, environment
        methods[method.name.lexeme] = function
      end

      klass = RLox::Class.new stmt.name.lexeme, methods
      environment.assign stmt.name, klass
      nil
    end

    def visit_if_stmt(stmt)
      if truthy? evaluate stmt.condition
        execute stmt.then_branch
      elsif stmt.else_branch
        execute stmt.else_branch
      end

      nil
    end

    def visit_logical_expr(expr)
      left = evaluate expr.left

      if expr.operator.type == TokenType::OR
        return left if truthy? left
      else
        return left unless truthy? left
      end

      evaluate expr.right
    end

    def visit_while_stmt(stmt)
      execute stmt.body while truthy? evaluate stmt.condition

      nil
    end

    def visit_call_expr(expr)
      callee = evaluate expr.callee

      arguments = expr.arguments.map do |argument|
        evaluate argument
      end

      raise RLox::RuntimeError.new expr.paren, 'Can only call functions and classes.' unless callee.callable?

      function = callee
      if arguments.size != function.arity
        raise RLox::RuntimeError.new expr.paren, "Expected #{function.arity} arguments but got #{arguments.size}."
      end

      function.call self, arguments
    end

    def visit_get_expr(expr)
      object = evaluate expr.object
      return object.get expr.name if object.is_a? Instance

      raise RLox::RuntimeError.new expr.name, 'Only instances have properties.'
    end

    def visit_set_expr(expr)
      object = evaluate expr.object

      raise RLox::RuntimeError.new expr.name, 'Only instances have fields.' unless object.is_a? Instance

      value = evaluate expr.value
      object.set expr.name, value
      value
    end

    def visit_this_expr(expr)
      look_up_variable expr.keyword, expr
    end

    def execute_block(statements, environment)
      previous = self.environment

      begin
        self.environment = environment

        statements.each do |statement|
          execute statement
        end
      ensure
        self.environment = previous
      end
    end

    def resolve(expr, depth)
      locals[expr] = depth
    end

    private

    attr_reader :locals
    attr_accessor :environment

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

    def look_up_variable(name, expr)
      distance = locals[expr]

      if distance
        environment.get_at distance, name.lexeme
      else
        globals.get name
      end
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
