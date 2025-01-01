# frozen_string_literal: true

class RLox
  class Expr
    class Literal < Expr
      attr_reader :value

      def initialize(value)
        @value = value
      end
    end
  end
end
