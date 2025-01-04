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

      scope.last[name.lexeme] = false
    end

    def define(name)
      return if scopes.empty?

      scopes.last[name.lexeme] = true
    end
  end
end
