# frozen_string_literal: true

class RLox
  class Expr
    class Literal < Expr
      attr_reader :value

      def initialize(value)
        @value = value
      end

      def accept(visitor)
        visitor.visit_literal_expr self
      end
    end
  end
end
