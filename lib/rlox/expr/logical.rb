# frozen_string_literal: true

class RLox
  class Expr
    class Logical < Expr
      attr_reader :left, :operator, :right

      def initialize(left, operator, right)
        @left = left
        @operator = operator
        @right = right
      end

      def accept(visitor)
        visitor.visit_logical_expr self
      end
    end
  end
end
