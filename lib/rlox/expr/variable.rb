# frozen_string_literal: true

class RLox
  class Expr
    class Variable < Expr
      attr_reader :name

      def initialize(name)
        @name = name
      end

      def accept(visitor)
        visitor.visit_variable_expr self
      end
    end
  end
end
