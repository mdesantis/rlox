# frozen_string_literal: true

class RLox
  class Resolver
    def initialize(interpreter)
      @interpreter = interpreter
      @scopes = []
    end

    def resolve(statements)
      case statements
      when Stmt then resolve_statement stmt
      when Expr then resolve_expression expr
      else
        statements.each do |statement|
          resolve_statement statement
        end
      end
    end

    def visit_block_stmt(stmt)
      begin_scope
      resolve stmt.statements
      end_scope

      nil
    end

    def visit_var_stmt(stmt)
      declare stmt.name
      resolve stmt.initializer if stmt.initializer
      define stmt.name
      nil
    end

    def visit_assign_expr(expr)
      resolve expr.value
      resolve_local expr, expr.name
      nil
    end

    def visit_variable_expr(expr)
      if !scopes.empty? && scopes.last[expr.name.lexeme] == false
        RLox.error "Can't read local vafiable in its own initializer.", token: expr.name
      end

      resolve_local expr, expr.name
      nil
    end

    def visit_function_stmt(stmt)
      declare stmt.name
      define stmt.name

      resolve_function stmt
      nil
    end

    def visit_expression_stmt(stmt)
      resolve stmt.expression
      nil
    end

    def visit_if_stmt(stmt)
      resolve stmt.condition
      resolve stmt.then_branch
      resolve stmt.else_branch if stmt.else_branch
      nil
    end

    def visit_print_stmt(stmt)
      resolve stmt.expression
      nil
    end

    def visit_return_stmt(stmt)
      resolve stmt.value if stmt.value
      nil
    end

    def visit_while_stmt(stmt)
      resolve stmt.condition
      resolve stmt.body
      nil
    end

    def visit_binary_expr(expr)
      resolve expr.left
      resolve expr.right
      nil
    end

    def visit_call_expr(expr)
      resolve expr.callee

      expr.arguments.each do |argument|
        resolve argument
      end

      nil
    end

    def visit_grouping_expr(expr)
      resolve expr.expression
      nil
    end

    def visit_literal_expr(_expr)
      nil
    end

    def visit_logical_expr(expr)
      resolve expr.left
      resolve expr.right
      nil
    end

    def visit_unary_expr(expr)
      resolve expr.right
      nil
    end

    private

    attr_reader :interpreter, :scopes

    def resolve_statement(stmt)
      stmt.accept self
    end

    def resolve_expression(expr)
      expr.accept self
    end

    def begin_scope
      scopes.push({})
    end

    def end_scope
      scopes.pop
    end

    def declare(name)
      return if scopes.empty?

      RLox.error 'Already a variable with this name in this scope', token: name if scope.key? name.lexeme

      scope.last[name.lexeme] = false
    end

    def define(name)
      return if scopes.empty?

      scopes.last[name.lexeme] = true
    end

    def resolve_local(expr, name)
      (scopes.size - 1).downto(0) do |i|
        if scopes[i].key? name.lexeme
          interpreter.resolve expr, scopes.size - 1 - i
          return
        end
      end
    end

    def resolve_function(function)
      begin_scope
      function.params.each do |param|
        declare param
        define param
      end
      resolve function.body
      end_scope
    end
  end
end
