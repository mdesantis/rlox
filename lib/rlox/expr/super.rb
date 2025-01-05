# frozen_string_literal: true

class RLox
  class Expr
    class Super < Stmt
      attr_reader :keyword, :method

      def initialize(keyword, method)
        @keyword = keyword
        @method = method
      end

      def accept(visitor)
        visitor.visit_super_expr self
      end
    end
  end
end
