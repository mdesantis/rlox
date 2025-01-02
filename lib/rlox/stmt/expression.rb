# frozen_string_literal: true

class RLox
  class Stmt
    class Expression < Stmt
      attr_reader :expression

      def initialize(expression)
        @expression = expression
      end
    end
  end
end
