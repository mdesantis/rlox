# frozen_string_literal: true

class RLox
  class Expr
    class Unary < Expr
      attr_reader :operator, :right

      def initialize(operator, right)
        @operator = operator
        @right = right
      end

      def accept(visitor)
        visitor.visit_unary_expr self
      end
    end
  end
end
