# frozen_string_literal: true

class RLox
  class Expr
    class Grouping < Expr
      attr_reader :expression

      def initialize(expression)
        @expression = expression
      end

      def accept(visitor)
        visitor.visit_grouping_expr self
      end
    end
  end
end
