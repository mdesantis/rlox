# frozen_string_literal: true

class RLox
  class Stmt
    class Print < Stmt
      attr_reader :expression

      def initialize(expression)
        @expression = expression
      end

      def accept(visitor)
        visitor.visit_print_stmt self
      end
    end
  end
end
