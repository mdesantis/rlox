# frozen_string_literal: true

class RLox
  class Expr
    class Call < Expr
      attr_reader :callee, :paren, :arguments

      def initialize(callee, paren, arguments)
        @callee = callee
        @paren = paren
        @arguments = arguments
      end

      def accept(visitor)
        visitor.visit_call_expr self
      end
    end
  end
end
