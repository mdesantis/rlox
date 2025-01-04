# frozen_string_literal: true

class RLox
  class Resolver
    def initialize(interpreter)
      @interpreter = interpreter
      @scopes = []
    end

    def resolve(statements)
      statements.each do |statement|
        resolve_statement statement
      end
    end

    def visit_block_stmt(stmt)
      begin_scope
      resolve stmt.statements
      end_scope

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
  end
end
