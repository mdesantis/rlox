# frozen_string_literal: true

class RLox
  class Stmt
    class While < Stmt
      attr_reader :condition, :body

      def initialize(condition, body)
        @condition = condition
        @body = body
      end

      def accept(visitor)
        visitor.visit_while_stmt self
      end
    end
  end
end
