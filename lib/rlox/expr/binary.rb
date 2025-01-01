# frozen_string_literal: true

class RLox
  class Expr
    class Binary < Expr
      attr_reader :left, :operator, :right

      def initialize(left, operator, right)
        @left = left
        @operator = operator
        @right = right
      end
    end
  end
end
