# frozen_string_literal: true

class RLox
  class Stmt
    class Expression < Stmt
      attr_reader :expression

      def initialize(expression)
        @expression = expression
      end

      def accept(visitor)
        visitor.visit_expression_stmt self
      end
    end
  end
end
