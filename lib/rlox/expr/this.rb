# frozen_string_literal: true

class RLox
  class Expr
    class This < Expr
      attr_reader :keyword

      def initialize(keyword)
        @keyword = keyword
      end

      def accept(visitor)
        visitor.visit_this_expr self
      end
    end
  end
end
