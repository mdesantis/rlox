# frozen_string_literal: true

class RLox
  class Expr
    class Assign < Expr
      attr_reader :name, :value

      def initialize(name, value)
        @name = name
        @value = value
      end

      def accept(visitor)
        visitor.visit_assign_expr self
      end
    end
  end
end
