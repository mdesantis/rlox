# frozen_string_literal: true

class RLox
  class Stmt
    class If < Stmt
      attr_reader :condition, :then_branch, :else_branch

      def initialize(condition, then_branch, else_branch)
        @condition = condition
        @then_branch = then_branch
        @else_branch = else_branch
      end

      def accept(visitor)
        visitor.visit_if_stmt self
      end
    end
  end
end
